import {Controller} from "stimulus"
import {tableSettings} from "../table/table_settings"
import Highcharts from 'highcharts'

export default class extends Controller {
    static targets = ["table", "card", "modal"]

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
                table.clear()
                let f = new Intl.NumberFormat('en-EN', {style: 'currency', currency: 'USD'})

                data.map(estate => {
                    let row = `
                            <tr data-murId="${estate['mur_id']}">
                                <td>${estate['date']}</td>
                                <td>
                                  <a href="${estate['url']}" target="_blank">${estate['address']}</a>
                                  </td>
                                <td>${estate['rooms']}</td>
                                <td>${estate['total_area']}</td>
                                <td data-action="click->estate-table#showHistory">${f.format(estate['price_usd'])}</td>
                                <td>${f.format(estate['meter_price_usd'])}</td>
                            </tr>
                           `
                    table.row.add($(row))
                })
                table.draw()
            })
    }

    showHistory(event) {
        console.log(event);
        let murId = event.target.parentNode.dataset.murid
        let name = event.target.parentElement.getElementsByTagName("td")[1].innerText
        let colors = ['#3E00EE', '#09a813']

        fetch(`estate/${murId}`)
            .then(res => res.json())
            .then(data => {
                console.log(data)

                $(this.modalTarget).modal()

                new Highcharts.Chart({
                    chart: {
                        renderTo: 'estateChart'
                    },
                    title: {text: name},
                    xAxis: [{
                        categories: data.map(row => row['date']),
                        crosshair: true
                    }],
                    yAxis: [{
                        labels: {
                            format: '{value} BYN'
                        },
                        title: {
                            text: ''
                        }
                    },
                        {
                            title: {
                                text: ''
                            },
                            labels: {
                                format: '{value} $'
                            },
                            opposite: true
                        }],
                    tooltip: {
                        shared: true
                    },
                    series: [{
                        name: "Цена m\xB2 BYN",
                        type: 'line',
                        color: colors[0],
                        data: data.map(row => row['meter_price']),
                        tooltip: {
                            valueSuffix: ' BYN'
                        }
                    },
                        {
                            name: "Цена m\xB2 $",
                            type: 'line',
                            color: colors[1],
                            yAxis: 1,
                            data: data.map(row => row['meter_price_usd']),
                            tooltip: {
                                valueSuffix: ' $'
                            }
                        }]
                })
            })
    }
}