/**
 * settings-ui.js
 * Logic for the Settings Page
 */

document.addEventListener('DOMContentLoaded', () => {
    // UI References
    const inputs = {
        odooUrl: document.getElementById('odooUrl'),
        database: document.getElementById('database'),
        username: document.getElementById('username'),
        password: document.getElementById('password'),

        modelJobOrder: document.getElementById('modelJobOrder'),
        modelCertificate: document.getElementById('modelCertificate'),
        fieldRelation: document.getElementById('fieldRelation'),

        fieldSerial: document.getElementById('fieldSerial'),
        fieldCertNo: document.getElementById('fieldCertNo'),
        fieldIssueDate: document.getElementById('fieldIssueDate'),
        fieldExpiryDate: document.getElementById('fieldExpiryDate')
    };

    const buttons = {
        save: document.getElementById('btn-save'),
        cancel: document.getElementById('btn-cancel'),
        test: document.getElementById('btn-test-connection'),
        export: document.getElementById('btn-export'),
        import: document.getElementById('btn-import'),
        reset: document.getElementById('btn-reset')
    };

    const statusDisplay = document.getElementById('status-display');
    const fileInput = document.getElementById('file-input');
    const tabs = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    // Load current config into inputs
    function loadValues() {
        const config = window.AppConfig.getAll();

        for (const [key, element] of Object.entries(inputs)) {
            if (config[key] !== undefined) {
                element.value = config[key];
            }
        }
    }

    // Save inputs to config
    function saveValues() {
        const newSettings = {};
        for (const [key, element] of Object.entries(inputs)) {
            newSettings[key] = element.value.trim();
        }

        window.AppConfig.save(newSettings);
        showStatus('Configuration saved successfully!', 'success');

        // Optional: Animate save button
        const originalText = buttons.save.innerText;
        buttons.save.innerText = 'Saved!';
        setTimeout(() => buttons.save.innerText = originalText, 1500);
    }

    // Show status message
    function showStatus(msg, type) {
        statusDisplay.textContent = msg;
        statusDisplay.className = `status-msg ${type}`;

        // Hide after 5 seconds
        setTimeout(() => {
            statusDisplay.style.display = 'none';
        }, 5000);
    }

    // Tab Switching
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            // Remove active class from all
            tabs.forEach(t => t.classList.remove('active'));
            tabContents.forEach(c => c.classList.remove('active'));

            // Add to current
            tab.classList.add('active');
            const targetId = tab.dataset.tab;
            document.getElementById(targetId).classList.add('active');

            // Show/Hide Test Connection button based on tab
            if (targetId === 'tab-connection') {
                buttons.test.style.display = 'block';
            } else {
                buttons.test.style.display = 'none';
            }
        });
    });

    // Event Listeners
    buttons.save.addEventListener('click', saveValues);

    buttons.cancel.addEventListener('click', () => {
        if (confirm('Discard unsaved changes?')) {
            loadValues(); // Reset to saved values
            window.location.href = 'index.html'; // Or just generic back
        }
    });

    buttons.reset.addEventListener('click', () => {
        if (confirm('Are you sure you want to reset all settings to defaults? This cannot be undone.')) {
            window.AppConfig.reset();
            loadValues();
            showStatus('Settings reset to defaults.', 'success');
        }
    });

    buttons.export.addEventListener('click', () => {
        window.AppConfig.exportToFile();
        showStatus('Configuration exported to file.', 'success');
    });

    buttons.import.addEventListener('click', () => {
        fileInput.click();
    });

    fileInput.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (event) => {
            const result = window.AppConfig.importFromJson(event.target.result);
            if (result.success) {
                loadValues();
                showStatus(result.message, 'success');
            } else {
                showStatus(result.message, 'error');
            }
            // Reset input so validation triggers again if same file selected
            fileInput.value = '';
        };
        reader.readAsText(file);
    });

    buttons.test.addEventListener('click', async () => {
        // Collect current values (even if not saved)
        const url = inputs.odooUrl.value.trim();
        const db = inputs.database.value.trim();
        const user = inputs.username.value.trim();
        const pass = inputs.password.value.trim(); // Need password for real test

        if (!url || !db || !user || !pass) {
            showStatus('Please fill in All Connection Details (including password) to test.', 'error');
            return;
        }

        // Temporarily save to config so Client can read it
        // We restore old values if user cancels, but for testing we need to set them
        window.AppConfig.save({
            odooUrl: url,
            database: db,
            username: user,
            password: pass
        });

        // Set button state
        const originalText = buttons.test.innerText;
        buttons.test.innerText = 'Connecting...';
        buttons.test.disabled = true;
        showStatus('Attempting to authenticate with Odoo...', 'success'); // using success style for blue/green neutral

        try {
            // Include odoo-client.js in HTML before testing, or assume it's loaded
            if (!window.OdooClient) {
                // Dynamic load if missing (though we added it to HTML layout in next step)
                await import('./odoo-client.js');
            }

            // Force re-init or clear cache if client keeps state
            window.OdooClient.uid = null;

            const uid = await window.OdooClient.authenticate();

            showStatus(`✅ Connection Successful! User ID: ${uid}`, 'success');

        } catch (error) {
            console.error(error);
            showStatus(`❌ Connection Failed: ${error.message}`, 'error');
        } finally {
            buttons.test.innerText = originalText;
            buttons.test.disabled = false;
        }
    });

    // Initialize
    loadValues();
});
