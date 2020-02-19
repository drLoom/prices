import {Controller} from "stimulus"
import {tableSettings} from "../table/table_settings"
import Highcharts from 'highcharts'

export default class extends Controller {
    static targets = ["avgPrice"]

    connect(){
        let priceContainer = this.avgPriceTarget
        fetch('estate/average_rate.json')
            .then((resp) => resp.json())
            .then(function (data) {
                // card.dispatchEvent(eventEnd)

                priceContainer.innerText = data.avg_meter_usd + " $"
            })
    }
}