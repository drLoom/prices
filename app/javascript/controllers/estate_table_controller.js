import {Controller} from "stimulus"
import {tableSettings} from "../table/table_settings";

export default class extends Controller {
    static targets = ["table", "card"]

    connect() {
        let table = $(this.tableTarget).DataTable(tableSettings.config)

        let card = this.cardTarget
        var eventStart = new Event('cardFetchStart')
        var eventEnd = new Event('cardFetchEnd')

        card.dispatchEvent(eventStart)

        fetch('estate.json')
            .then((resp) => resp.json())
            .then(function (data) {
                card.dispatchEvent(eventEnd)
                // let table = $('#estate-table').DataTable()
                table.clear()
                let f = new Intl.NumberFormat('en-EN', {style: 'currency', currency: 'USD'})

                data.map(estate => {
                    let row = `
                            <tr>
                                <td>${estate['date']}</td>
                                <td>
                                  <a href="${estate['url']}" target="_blank">${estate['address']}</a>
                                  </td>
                                <td>${estate['rooms']}</td>
                                <td>${estate['total_area']}</td>
                                <td>${f.format(estate['price_usd'])}</td>
                                <td>${f.format(estate['meter_price_usd'])}</td>
                            </tr>
                           `
                    table.row.add($(row))
                })
                table.draw()
            })
    }
}