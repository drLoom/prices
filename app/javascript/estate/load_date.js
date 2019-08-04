document.addEventListener("turbolinks:load", function () {
    fetch('estate.json')
        .then((resp) => resp.json())
        .then(function (data) {
            let table = $('#estate-table').DataTable()
            table.clear()

            data.forEach(estate => {
                let row = `
                            <tr>
                                <td>${estate['date']}</td>
                                <td>
                                  <a href="${estate['url']}">${estate['address']}</a>
                                  </td>
                                <td>${estate['rooms']}</td>
                                <td>${estate['total_area']}</td>
                                <td>${estate['price']}</td>
                                <td>${estate['price_usd']}</td>
                                <td>${estate['meter_price']}</td>
                                <td>${estate['meter_price_usd']}</td>
                            </tr>
                           `
                table.row.add($(row))
            })

            table.draw()
        })
})