const tableSettings = {
    config: {
        orderCellsTop: true,
        ordering: true,
        paging: true,
        order: [[0, "asc"]],
        lengthMenu: [[10, 15, 25, 50, 75, 100, -1], [10, 15, 25, 50, 75, 100, 'All']],
        iDisplayLength: 15,
        initComplete: function () {
            this.find('tfoot th').each(function () {
                $(this).html(`<input type="text" placeholder="" />`);
            })

            this.find('tfoot').css('display', 'table-header-group')

            this.api().columns().every(function () {
                var column = this;

                let input = $('input', this.footer());
                input.on('keyup change', function () {
                    if (column.search() !== this.value) {
                        column
                            .search(this.value)
                            .draw()
                    }
                });
            });
        }
    }
}

export {tableSettings}
