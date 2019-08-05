document.addEventListener("turbolinks:load", function () {
    let spinner = require('./spinner')

    let cardBody = document.getElementById('estate-table').closest('div.card-body')
    let cardHeader = cardBody.previousSibling

    cardHeader.insertAdjacentHTML('beforeend', spinner.spinnerMarkUp())
    cardBody.style.display = 'none'

    fetch('estate.json')
        .then((resp) => resp.json())
        .then(function (data) {
            let table = $('#estate-table').DataTable()
            table.clear()
            let f = new Intl.NumberFormat('en-EN', { style: 'currency', currency: 'USD' })

            data.map(estate => {
                let row = `
                            <tr>
                                <td>${estate['date']}</td>
                                <td>
                                  <a href="${estate['url']}">${estate['address']}</a>
                                  </td>
                                <td>${estate['rooms']}</td>
                                <td>${estate['total_area']}</td>
                                <td>${f.format(estate['price_usd'])}</td>
                                <td>${f.format(estate['meter_price_usd'])}</td>
                            </tr>
                           `
                table.row.add($(row))
            })
            cardBody.style.display = "block";
            table.draw()
            cardHeader.getElementsByClassName('spinner')[0].remove()
        })
})