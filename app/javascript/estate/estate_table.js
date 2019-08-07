document.addEventListener("turbolinks:load", function () {
    let tableId = '#estate-table'

    $(`${tableId} tfoot th`).each(function () {
        $(this).html(`<input type="text" placeholder="" />`);
    });

    var table = $(tableId).DataTable({
        orderCellsTop: true,
        ordering: true,
        paging: true,
        order: [[0, "asc"]],
        lengthMenu: [[10, 15, 25, 50, 75, 100, -1], [10, 15, 25, 50, 75, 100, 'All']],
        iDisplayLength: 15,
        initComplete: function () {
            $(`${tableId} tfoot`).css('display', 'table-header-group')

            let i = 0;
            this.api().columns().every(function () {
                var column = this;

                input = $('input', this.footer());
                input.on('keyup change', function () {
                    if (i === 5) {

                    } else {
                        if (column.search() !== this.value) {
                            column
                                .search(this.value)
                                .draw();
                        }
                    }
                });
            });
        }
    });
});
