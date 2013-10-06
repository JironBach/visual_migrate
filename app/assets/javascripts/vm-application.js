//= #require jquery-ui-rails

function deleteTableRow(tableID) {
    if(!confirm('Really delete?')) return;

    try {
        var table = document.getElementById(tableID);
        var rowCount = table.rows.length;

        for(var i=0; i<rowCount; i++) {
            var row = table.rows[i];
            var chkbox = row.cells[0].childNodes[0];
            if(null != chkbox && true == chkbox.checked) {
                table.deleteRow(i);
                rowCount--;
                i--;
            }
        }
    }catch(e) {
        alert(e);
    }
}

function updateColumnsDiv(table_id, update_div, method_name, func_name, row_num) {
  jQuery.ajax({
    url: "/visual_migrate/index/show_select_columns",
    type: "POST",
    async: true,
    data: {"table_name" : table_id, "method_name" : method_name, "func_name" : func_name, "row_num" : row_num},
    dataType: "html",
    success: function(data) {
      jQuery(document.getElementById(update_div)).html(data);
    }
  });
}
