document.addEventListener('DOMContentLoaded', () => {
    // Input Elements
    const serialInput = document.getElementById('serial');
    const calDateInput = document.getElementById('calibrationDate');
    const dueDateInput = document.getElementById('dueDate');
    const certInput = document.getElementById('certificate');

    // Default Values
    const today = new Date();
    const nextYear = new Date();
    nextYear.setFullYear(today.getFullYear() + 1);

    calDateInput.valueAsDate = today;
    dueDateInput.valueAsDate = nextYear;
    serialInput.value = 'SN-000000';
    certInput.value = 'CERT-001';

    // Update Function
    function updatePreviews() {
        const serial = serialInput.value || '';
        const calDate = formatDate(calDateInput.value);
        const dueDate = formatDate(dueDateInput.value);
        const cert = certInput.value || '';

        // Update all fields in all previews
        document.querySelectorAll('.val-serial').forEach(el => el.textContent = serial);
        document.querySelectorAll('.val-cal').forEach(el => el.textContent = calDate);
        document.querySelectorAll('.val-due').forEach(el => el.textContent = dueDate);
        document.querySelectorAll('.val-cert').forEach(el => el.textContent = cert);
    }

    function formatDate(dateString) {
        if (!dateString) return '';
        const d = new Date(dateString);
        // Format as DD/MM/YYYY
        return d.toLocaleDateString('en-GB'); 
    }

    // Event Listeners
    [serialInput, calDateInput, dueDateInput, certInput].forEach(input => {
        input.addEventListener('input', updatePreviews);
    });

    // Initial Update
    updatePreviews();
});

// Print Function (Global for onclick)
function printLabel(sizeId) {
    const wrapperSelector = `.label-wrapper:has(#preview-${sizeId})`; 
    // Fallback if :has is not supported (it is in most modern browsers, but let's be safe)
    // We will just find the parent
    const previewEl = document.getElementById(`preview-${sizeId}`);
    const wrapper = previewEl.closest('.label-wrapper');

    if (wrapper) {
        // Add classes for print styling
        document.body.classList.add('printing');
        wrapper.classList.add('active-print');

        // Trigger print
        window.print();

        // Cleanup after print dialog closes
        // Note: This happens immediately in some browsers, so we might not see the hiding effect visually
        // but it effectively controls what is sent to the spooler.
        setTimeout(() => {
            document.body.classList.remove('printing');
            wrapper.classList.remove('active-print');
        }, 500);
    }
}
