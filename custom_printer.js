document.addEventListener('DOMContentLoaded', () => {
    // Inputs
    const inputs = {
        serial: document.getElementById('input-serial'),
        cal: document.getElementById('input-cal'),
        due: document.getElementById('input-due'),
        cert: document.getElementById('input-cert')
    };

    // Displays (Preview)
    const displays = {
        serial: document.getElementById('val-serial'),
        cal: document.getElementById('val-cal'),
        due: document.getElementById('val-due'),
        cert: document.getElementById('val-cert')
    };

    // Preview Lines (for font size)
    const lines = {
        serial: document.getElementById('line-serial'),
        cal: document.getElementById('line-cal'),
        due: document.getElementById('line-due'),
        cert: document.getElementById('line-cert')
    };

    // Configs
    const config = {
        size: document.getElementById('config-size'),
        fontsize: document.getElementById('config-fontsize'),
        gap: document.getElementById('config-gap'),
        border: document.getElementById('config-border'),
        margin: document.getElementById('config-margin'), // Now Content Padding
        inset: document.getElementById('config-inset')   // Now Border Margin
    };

    // Config Displays (Labels next to sliders)
    const configDisplays = {
        fontsize: document.getElementById('display-fontsize'),
        gap: document.getElementById('display-gap'),
        margin: document.getElementById('display-margin'),
        inset: document.getElementById('display-inset'),
        dims: document.getElementById('display-dims')
    };

    // Internal State for Per-Field Styles
    const fieldState = {
        serial: { sizeMod: 0, bold: false },
        cal: { sizeMod: 0, bold: false },
        due: { sizeMod: 0, bold: false },
        cert: { sizeMod: 0, bold: false }
    };

    // Defaults
    const today = new Date();
    const nextYear = new Date();
    nextYear.setFullYear(today.getFullYear() + 1);

    inputs.cal.valueAsDate = today;
    inputs.due.valueAsDate = nextYear;
    inputs.serial.value = 'SN-000000';
    inputs.cert.value = 'CERT-001';

    // --- Core Functions ---

    function updatePreviewData() {
        displays.serial.textContent = inputs.serial.value || '';
        displays.cal.textContent = formatDate(inputs.cal.value);
        displays.due.textContent = formatDate(inputs.due.value);
        displays.cert.textContent = inputs.cert.value || '';
    }

    function updateConfig() {
        const sizeVal = config.size.value; // e.g., "12-28"
        const baseFontVal = parseFloat(config.fontsize.value);
        const gapVal = config.gap.value;
        const borderVal = config.border.checked;
        const marginVal = config.margin.value; // Content Padding
        const insetVal = config.inset.value;   // Border Margin

        // 1. Update Size
        let widthMm, heightMm;
        switch (sizeVal) {
            case '12-28': widthMm = 28; heightMm = 12; break;
            case '18-35': widthMm = 35; heightMm = 18; break;
            case '24-44': widthMm = 44; heightMm = 24; break;
            default: widthMm = 28; heightMm = 12;
        }

        updateCssVar('--preview-width', `${widthMm}mm`);
        updateCssVar('--preview-height', `${heightMm}mm`);
        configDisplays.dims.textContent = `${heightMm}mm x ${widthMm}mm`;

        // 2. Update Base Font Size & Line Gap
        updateCssVar('--preview-font-size', `${baseFontVal}pt`);
        configDisplays.fontsize.textContent = `${baseFontVal}pt`;

        updateCssVar('--preview-line-gap', `${gapVal}mm`);
        configDisplays.gap.textContent = `${gapVal}mm`;

        // 3. Update Border, Inset, & Padding
        const borderStyle = borderVal ? '1px solid #000' : 'none';
        updateCssVar('--preview-border', borderStyle);

        // Inset (Space from paper edge to border)
        updateCssVar('--preview-border-inset', `${insetVal}mm`);
        configDisplays.inset.textContent = `${insetVal}mm`;

        // Padding (Space inside border)
        updateCssVar('--preview-content-padding', `${marginVal}mm`);
        configDisplays.margin.textContent = `${marginVal}mm`;

        // 4. Update Per-Field Overrides
        Object.keys(fieldState).forEach(key => {
            const state = fieldState[key];
            const lineEl = lines[key];
            const valEl = displays[key];

            // Font Size: Base + Mod
            const finalSize = baseFontVal + state.sizeMod;
            if (state.sizeMod !== 0) {
                lineEl.style.fontSize = `${finalSize}pt`;
            } else {
                lineEl.style.fontSize = ''; // Reset to inherit base
            }

            // Bold: Apply to the VALUE span
            valEl.style.fontWeight = state.bold ? '900' : 'inherit';
        });
    }

    function updateCssVar(name, value) {
        document.documentElement.style.setProperty(name, value);
    }

    function formatDate(dateString) {
        if (!dateString) return '';
        const d = new Date(dateString);
        return d.toLocaleDateString('en-GB');
    }

    // --- Control Handlers ---

    function handleFieldControl(field, action) {
        const state = fieldState[field];
        if (!state) return;

        if (action === 'plus') {
            state.sizeMod += 0.5;
        } else if (action === 'minus') {
            state.sizeMod -= 0.5;
        } else if (action === 'bold') {
            state.bold = !state.bold;
            // Toggle active class on button
            const btn = document.querySelector(`.control-group[data-field="${field}"] .btn-bold`);
            if (btn) btn.classList.toggle('active', state.bold);
        }

        updateConfig(); // Re-render styles
    }

    // --- Event Listeners ---

    // Data Inputs
    Object.values(inputs).forEach(el => {
        el.addEventListener('input', updatePreviewData);
    });

    // Config Inputs
    Object.values(config).forEach(el => {
        el.addEventListener('input', updateConfig);
    });

    // Tool Buttons
    document.querySelectorAll('.btn-mini').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            const group = btn.closest('.control-group');
            const field = group.dataset.field;

            if (btn.classList.contains('btn-plus')) handleFieldControl(field, 'plus');
            if (btn.classList.contains('btn-minus')) handleFieldControl(field, 'minus');
            if (btn.classList.contains('btn-bold')) handleFieldControl(field, 'bold');
        });
    });

    // Initial Run
    updatePreviewData();
    updateConfig();

    // Print Button
    document.getElementById('btn-print').addEventListener('click', () => {
        window.print();
    });
});
