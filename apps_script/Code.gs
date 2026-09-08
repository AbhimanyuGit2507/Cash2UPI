function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    
    // Write to Transactions sheet
    var txSheet = ss.getSheetByName("Transactions");
    if (!txSheet) {
      txSheet = ss.insertSheet("Transactions");
      txSheet.appendRow(["Date", "Time", "Type", "Bank", "Amount", "Cash", "Commission", "Category", "Notes", "Source", "Status", "User"]);
    }
    
    txSheet.appendRow([
      data.date,
      data.time,
      data.type,
      data.bank,
      data.amount,
      data.cash,
      data.commission,
      data.category,
      data.notes,
      data.source,
      data.status,
      data.user_name || ""
    ]);
    
    return ContentService.createTextOutput(JSON.stringify({"status": "success"}))
      .setMimeType(ContentService.MimeType.JSON);
  } catch(error) {
    return ContentService.createTextOutput(JSON.stringify({"status": "error", "message": error.toString()}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
