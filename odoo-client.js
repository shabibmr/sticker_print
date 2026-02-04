/**
 * odoo-client.js
 * Handles XML-RPC communication with Odoo instance
 */

class OdooClient {
    constructor() {
        this.uid = null;
    }

    getConfig() {
        return window.AppConfig.getAll();
    }

    /**
     * Helper to construct XML-RPC methodCall
     */
    buildXmlCall(methodName, params) {
        let paramsXml = '';
        params.forEach(p => {
            paramsXml += `<param><value>${this.toXmlRpcValue(p)}</value></param>`;
        });

        return `<?xml version="1.0"?>
<methodCall>
    <methodName>${methodName}</methodName>
    <params>${paramsXml}</params>
</methodCall>`;
    }

    /**
     * Convert JS value to XML-RPC value
     */
    toXmlRpcValue(val) {
        if (val === null || val === undefined) return '<nil/>';

        const type = typeof val;

        if (type === 'boolean') return `<boolean>${val ? '1' : '0'}</boolean>`;
        if (type === 'number') {
            return Number.isInteger(val)
                ? `<int>${val}</int>`
                : `<double>${val}</double>`;
        }
        if (type === 'string') return `<string>${this.escapeXml(val)}</string>`;

        if (Array.isArray(val)) {
            const items = val.map(v => `<value>${this.toXmlRpcValue(v)}</value>`).join('');
            return `<array><data>${items}</data></array>`;
        }

        if (type === 'object') {
            const members = Object.keys(val).map(k => `
                <member>
                    <name>${this.escapeXml(k)}</name>
                    <value>${this.toXmlRpcValue(val[k])}</value>
                </member>
            `).join('');
            return `<struct>${members}</struct>`;
        }

        return `<string>${this.escapeXml(String(val))}</string>`;
    }

    escapeXml(str) {
        return str.replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&apos;');
    }

    /**
     * Parse XML-RPC response
     */
    parseXmlResponse(xmlText) {
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(xmlText, "text/xml");

        // Check for fault
        const fault = xmlDoc.querySelector('methodResponse > fault');
        if (fault) {
            const errVal = this.parseXmlValue(fault.querySelector('value'));
            throw new Error(`Odoo Error: ${errVal.faultString} (${errVal.faultCode})`);
        }

        const param = xmlDoc.querySelector('methodResponse > params > param > value');
        if (!param) throw new Error('Invalid XML-RPC response');

        return this.parseXmlValue(param);
    }

    parseXmlValue(valNode) {
        const child = valNode.firstElementChild;
        if (!child) return valNode.textContent; // string fallback

        const type = child.tagName;

        if (type === 'string') return child.textContent;
        if (type === 'int' || type === 'i4') return parseInt(child.textContent, 10);
        if (type === 'double') return parseFloat(child.textContent);
        if (type === 'boolean') return child.textContent === '1';
        if (type === 'nil') return null;

        if (type === 'array') {
            const dataNode = child.querySelector('data');
            if (!dataNode) return [];
            return Array.from(dataNode.children).map(v => this.parseXmlValue(v));
        }

        if (type === 'struct') {
            const obj = {};
            Array.from(child.children).forEach(member => {
                const name = member.querySelector('name').textContent;
                const value = member.querySelector('value');
                obj[name] = this.parseXmlValue(value);
            });
            return obj;
        }

        return child.textContent;
    }

    /**
     * Execute XML-RPC fetch
     */
    async execute(endpoint, method, params) {
        const config = this.getConfig();
        const url = `${config.odooUrl}/xmlrpc/2/${endpoint}`;

        const body = this.buildXmlCall(method, params);

        try {
            const response = await fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'text/xml'
                },
                body: body
            });

            if (!response.ok) {
                throw new Error(`HTTP Error: ${response.status} ${response.statusText}`);
            }

            const text = await response.text();
            return this.parseXmlResponse(text);

        } catch (error) {
            console.error('XML-RPC Call Failed:', error);
            throw error;
        }
    }

    /**
     * Authenticate and get UID
     */
    async authenticate() {
        const config = this.getConfig();

        // params: db, login, password, empty_dict
        const params = [
            config.database,
            config.username,
            config.password,
            {}
        ];

        console.log('Authenticating...');
        const uid = await this.execute('common', 'authenticate', params);

        if (!uid) {
            throw new Error('Authentication failed. Check credentials.');
        }

        this.uid = uid;
        console.log('Authenticated! UID:', uid);
        return uid;
    }

    /**
     * Search and Read (Main data fetching method)
     */
    async searchRead(model, domain = [], fields = []) {
        const config = this.getConfig();
        if (!this.uid) await this.authenticate();

        // execute_kw params: db, uid, password, model, method, args(list), kwargs(struct)
        const params = [
            config.database,
            this.uid,
            config.password,
            model,
            'search_read',
            [domain], // args: [domain]
            { fields: fields, limit: 100 } // kwargs
        ];

        return await this.execute('object', 'execute_kw', params);
    }

    /**
     * Helper: List Job Orders
     */
    async listJobOrders(searchTerm = '') {
        const config = this.getConfig();
        const model = config.modelJobOrder || 'project.project';

        let domain = [];
        if (searchTerm) {
            domain.push(['name', 'ilike', searchTerm]);
        }

        // We fetch name and id as minimal requirement
        return await this.searchRead(model, domain, ['id', 'name']);
    }

    /**
     * Helper: List Certificates for a Job Order
     */
    async listCertificates(jobOrderId) {
        const config = this.getConfig();
        const model = config.modelCertificate || 'quality.certificate';
        const relationField = config.fieldRelation || 'project_id';

        // Maps
        const fSerial = config.fieldSerial || 'slno';
        const fCertNo = config.fieldCertNo || 'certificate_number';
        const fIssue = config.fieldIssueDate || 'issue_date';
        const fExpiry = config.fieldExpiryDate || 'expiry_date';

        // Domain: Relation Field = jobOrderId
        const domain = [[relationField, '=', jobOrderId]];

        // Fields to fetch
        const fields = ['id', 'name', fSerial, fCertNo, fIssue, fExpiry];

        const results = await this.searchRead(model, domain, fields);

        // Normalize results
        return results.map(rec => ({
            id: rec.id,
            name: rec.name || 'No Name', // Default name

            // Normalized fields for our app
            serial: rec[fSerial] || '',
            certNo: rec[fCertNo] || '',
            issueDate: rec[fIssue] || '',
            expiryDate: rec[fExpiry] || ''
        }));
    }
}

// Export global
window.OdooClient = new OdooClient();
