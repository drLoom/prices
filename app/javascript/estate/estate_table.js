$(function () {
    let tableId = '#estate-table'

    $(`${tableId} thead tr:eq(1) th`).each(function () {
        var title = $(this).text();
        $(this).html(`<input type="text" placeholder="${title}" />`);
    });

    var table = $(tableId).DataTable({
        orderCellsTop: true,
        ordering: true,
        paging: true,
        order: [[0, "asc"]],
        iDisplayLength: 25,
        initComplete: function () {
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
