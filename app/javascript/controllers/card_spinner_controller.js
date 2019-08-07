import { Controller } from "stimulus"
import style from "../styles/spinner.scss"

export default class extends Controller {
    static targets = [ "card", "spinner" ]

    connect() {
        this.cardTarget.addEventListener('cardFetchStart', e => {
            e.stopPropagation()
            this.hideCardBody()
        })

        this.cardTarget.addEventListener('cardFetchEnd', e => {
            e.stopPropagation()
            this.showCardBody()
        })
    }

    cardBody() {
        return this.cardTarget.getElementsByClassName('card-body')[0]
    }

    hideCardBody(){
        this.cardBody().style.display = 'none'
        this.spinnerTarget.setAttribute('style', 'display: flex !important')
    }

    showCardBody(){
        this.cardBody().style.display = 'block'
        this.spinnerTarget.setAttribute('style', 'display: none !important')
    }
}