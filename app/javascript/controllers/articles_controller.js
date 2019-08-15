import {Controller} from "stimulus"
import {tableSettings} from "../table/table_settings";

export default class extends Controller {
    static targets = ["modal", "table"]

    connect() {
        $(this.tableTarget).DataTable(tableSettings.config)
    }

    show(event){
        event.preventDefault()
        const modal = this.modalTarget
        modal.getElementsByClassName('modal-content')[0].innerHTML = '<iframe style="width: 85em; height: 50em;"></iframe>'
        const iframe = modal.getElementsByTagName('iframe')[0]

        $(modal).modal()

        fetch(`/articles/${event.target.text}`)
            .then(resp => resp.text())
            .then(text => {
                modal.getElementsByTagName('iframe')[0].contentWindow.document.write(text)
            })
    }
}