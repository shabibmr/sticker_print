/**
 * odoo-browser.js
 * Logic for browsing Odoo data and printing stickers
 */

document.addEventListener('DOMContentLoaded', () => {
    // UI References
    const elements = {
        jobsList: document.getElementById('list-jobs'),
        certsList: document.getElementById('list-certs'),
        searchJobs: document.getElementById('search-jobs'),
        selectedJobName: document.getElementById('selected-job-name'),
        appStatus: document.getElementById('app-status'),

        // Hidden Inputs (Bridge to custom_printer.js)
        inputSerial: document.getElementById('input-serial'),
        inputCal: document.getElementById('input-cal'),
        inputDue: document.getElementById('input-due'),
        inputCert: document.getElementById('input-cert')
    };

    let allJobs = []; // Cache jobs for search
    let currentCertificates = [];

    // --- Data Fetching ---

    async function loadJobOrders() {
        setLoading(elements.jobsList, 'Loading Job Orders...');

        try {
            if (!window.OdooClient) {
                throw new Error('Odoo Client not initialized');
            }

            // Attempt to fetch
            const jobs = await window.OdooClient.listJobOrders();
            allJobs = jobs; // Cache
            renderJobsList(jobs);

            setStatus('Job Orders loaded.');

        } catch (error) {
            console.error(error);
            setError(elements.jobsList, `Failed to load jobs: ${error.message}. <br><a href="settings-ui.html">Check Settings</a>`);
            setStatus('Connection failed.');
        }
    }

    async function loadCertificates(jobId, jobName) {
        setLoading(elements.certsList, 'Loading Certificates...');
        elements.selectedJobName.textContent = jobName;

        try {
            const certs = await window.OdooClient.listCertificates(jobId);
            currentCertificates = certs;
            renderCertsList(certs);

            if (certs.length === 0) {
                setEmpty(elements.certsList, 'No certificates found for this job.');
            } else {
                setStatus(`${certs.length} certificates found.`);
            }

        } catch (error) {
            console.error(error);
            setError(elements.certsList, `Failed to load certificates: ${error.message}`);
        }
    }

    // --- Rendering ---

    function renderJobsList(jobs) {
        elements.jobsList.innerHTML = '';

        if (jobs.length === 0) {
            setEmpty(elements.jobsList, 'No job orders found.');
            return;
        }

        jobs.forEach(job => {
            const el = document.createElement('div');
            el.className = 'list-item';
            el.innerHTML = `
                <span class="item-title">${job.name}</span>
                <span class="item-meta">ID: ${job.id}</span>
            `;
            el.onclick = () => {
                // Highlight logic
                document.querySelectorAll('#list-jobs .list-item').forEach(i => i.classList.remove('active'));
                el.classList.add('active');

                loadCertificates(job.id, job.name);
            };
            elements.jobsList.appendChild(el);
        });
    }

    function renderCertsList(certs) {
        elements.certsList.innerHTML = '';

        certs.forEach(cert => {
            const el = document.createElement('div');
            el.className = 'list-item';
            el.innerHTML = `
                <span class="item-title">${cert.certNo || 'No Cert No'}</span>
                <span class="item-meta">S/N: ${cert.serial || '-'}</span>
                <div class="item-meta" style="font-size: 0.75rem; margin-top:4px;">
                    Issued: ${cert.issueDate || '-'}
                </div>
            `;
            el.onclick = () => {
                document.querySelectorAll('#list-certs .list-item').forEach(i => i.classList.remove('active'));
                el.classList.add('active');

                selectCertificate(cert);
            };
            elements.certsList.appendChild(el);
        });
    }

    // --- Logic ---

    function selectCertificate(cert) {
        // Populate hidden inputs
        elements.inputSerial.value = cert.serial || '';
        elements.inputCert.value = cert.certNo || '';

        // Handle dates (Ensure YYYY-MM-DD format for date inputs if they were date inputs, 
        // but we switched them to text in HTML to handle raw string data better, 
        // however custom_printer.js might expect date objects or strings to format)

        // custom_printer.js uses valueAsDate or value. 
        // If we kept them as type="text" (hidden), we just set value.
        // But custom_printer.js might try to format them.
        // Let's assume Odoo returns "YYYY-MM-DD".

        elements.inputCal.value = cert.issueDate || '';
        elements.inputDue.value = cert.expiryDate || '';

        // Trigger 'input' event so custom_printer.js updates the preview
        triggerEvent(elements.inputSerial, 'input');
        triggerEvent(elements.inputCert, 'input');
        triggerEvent(elements.inputCal, 'input');
        triggerEvent(elements.inputDue, 'input');

        setStatus(`Selected: ${cert.certNo}`);
    }

    function triggerEvent(el, type) {
        const e = new Event(type);
        el.dispatchEvent(e);
    }

    // --- Search ---

    elements.searchJobs.addEventListener('input', (e) => {
        const term = e.target.value.toLowerCase();
        const filtered = allJobs.filter(job => job.name.toLowerCase().includes(term));
        renderJobsList(filtered);
    });

    // --- Helpers ---

    function setLoading(container, msg) {
        container.innerHTML = `<div class="loading-state">${msg}</div>`;
    }

    function setEmpty(container, msg) {
        container.innerHTML = `<div class="empty-state">${msg}</div>`;
    }

    function setError(container, msg) {
        container.innerHTML = `<div class="error-state">${msg}</div>`;
    }

    function setStatus(msg) {
        elements.appStatus.innerHTML = msg;
    }

    // Initial Load
    loadJobOrders();

});
