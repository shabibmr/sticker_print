/**
 * config.js
 * Manages configuration for Odoo Sticker Printer Connection
 */

const Config = {
    // Default Configuration
    defaults: {
        // Connection
        odooUrl: '',
        database: '',
        username: '',
        password: '', // Stored in cleartext in localStorage (user warned in UI)

        // Models
        modelJobOrder: 'project.project',
        modelCertificate: 'quality.certificate',
        fieldRelation: 'project_id', // Field in Certificate linking to Job Order

        // Field Mappings (Certificate Model)
        fieldSerial: 'slno',
        fieldCertNo: 'certificate_number',
        fieldIssueDate: 'issue_date',
        fieldExpiryDate: 'expiry_date'
    },

    // Current settings
    settings: {},

    // Initialize
    init() {
        this.load();
    },

    // Load from localStorage
    load() {
        const stored = localStorage.getItem('odoo_printer_config');
        if (stored) {
            try {
                const parsed = JSON.parse(stored);
                // Merge with defaults to ensure all keys exist
                this.settings = { ...this.defaults, ...parsed };
            } catch (e) {
                console.error('Failed to parse config:', e);
                this.settings = { ...this.defaults };
            }
        } else {
            this.settings = { ...this.defaults };
        }
    },

    // Save to localStorage
    save(newSettings) {
        this.settings = { ...this.settings, ...newSettings };
        localStorage.setItem('odoo_printer_config', JSON.stringify(this.settings));
        console.log('Configuration saved');
    },

    // Reset to defaults
    reset() {
        this.settings = { ...this.defaults };
        localStorage.setItem('odoo_printer_config', JSON.stringify(this.settings));
    },

    // Export configuration as JSON file
    exportToFile() {
        const dataStr = JSON.stringify(this.settings, null, 2);
        const dataUri = 'data:application/json;charset=utf-8,' + encodeURIComponent(dataStr);

        const exportFileDefaultName = 'odoo_printer_config.json';

        const linkElement = document.createElement('a');
        linkElement.setAttribute('href', dataUri);
        linkElement.setAttribute('download', exportFileDefaultName);
        linkElement.click();
    },

    // Import configuration from JSON string
    importFromJson(jsonStr) {
        try {
            const parsed = JSON.parse(jsonStr);
            // Basic validation: check if it looks like a config object
            if (typeof parsed === 'object' && parsed !== null) {
                this.save(parsed);
                return { success: true, message: 'Configuration imported successfully.' };
            } else {
                return { success: false, message: 'Invalid configuration format.' };
            }
        } catch (e) {
            return { success: false, message: 'Invalid JSON file.' };
        }
    },

    // Get a specific setting
    get(key) {
        return this.settings[key];
    },

    // Get all settings
    getAll() {
        return { ...this.settings };
    }
};

// Initialize on load
Config.init();

// Export for module usage (if using modules) or global (if using script tags)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = Config;
} else {
    window.AppConfig = Config;
}
