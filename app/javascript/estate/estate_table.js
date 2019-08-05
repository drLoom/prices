document.addEventListener("turbolinks:load", function () {
    let tableId = '#estate-table'

    $(`${tableId} tfoot th`).each(function () {
        var title = $(this).text();
        $(this).html(`<input type="text" placeholder="${title}" />`);
    });

    var table = $(tableId).DataTable({
        orderCellsTop: true,
        ordering: true,
        paging: true,
        order: [[0, "asc"]],
        iDisplayLength: 15,
        initComplete: function () {
            $(`${tableId} tfoot`).css('display', 'table-header-group')

            this.api().columns().every(function () {
                var column = this;

                input = $('input', this.footer());
                input.on('keyup change', function () {
                    if (column.search() !== this.value) {
                        column
                            .search(this.value)
                            .draw();
                    }
                });
            });
        }
    });
});
