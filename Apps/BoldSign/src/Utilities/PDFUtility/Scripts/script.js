async function MergePDFs(pdfContentsArray) {
    try {
        const { PDFDocument } = PDFLib;
        const mergedPdf = await PDFDocument.create();
        
        // Parse JSON array if it's a string
        const pdfsToMerge = typeof pdfContentsArray === 'string' 
            ? JSON.parse(pdfContentsArray) 
            : pdfContentsArray;

        for (const base64Content of pdfsToMerge) {
            // Convert base64 to Uint8Array
            const pdfBytes = Uint8Array.from(atob(base64Content), c => c.charCodeAt(0));
            
            // Load the PDF document
            const pdf = await PDFDocument.load(pdfBytes);
            
            // Copy all pages from the current PDF to the merged document
            const copiedPages = await mergedPdf.copyPages(pdf, pdf.getPageIndices());
            copiedPages.forEach(page => mergedPdf.addPage(page));
        }

        // Save the merged PDF
        const mergedPdfBytes = await mergedPdf.save();
        
        // Convert to base64
        const mergedBase64 = btoa(
            new Uint8Array(mergedPdfBytes)
                .reduce((data, byte) => data + String.fromCharCode(byte), '')
        );

        // Trigger the MergeComplete event with the merged PDF content
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('MergeComplete', [mergedBase64]);
    } catch (error) {
        console.error('PDF merge error:', error);
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('MergeError', [error.message]);
    }
}