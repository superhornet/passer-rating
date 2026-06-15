import { ScrollbarHandler } from "./ScrollBarHandler.ts";
import { AntiPollution } from "./AntiPollution.ts";
interface RatingAPIType {
    id?: number | bigint,
    qb_name_f: string,
    qb_name_l: string,
    attempts: number,
    completions: number,
    yards: number,
    touchdowns: number,
    interceptions: number,
    team: string
}
class PlayerRating {
    private playerFormClose: HTMLElement;
    private playerFormAction: HTMLButtonElement;
    private addRating: HTMLButtonElement;
    private nextPage: HTMLElement;
    private prevPage: HTMLElement;
    private pageSize: HTMLSelectElement;
    constructor() {
        this.playerFormAction = document.getElementById('playerFormAct') as HTMLButtonElement;
        this.addRating = document.getElementById('addRating') as HTMLButtonElement;
        this.playerFormClose = document.getElementById('formClose') as HTMLElement;
        this.nextPage = document.getElementById('btnFwd') as HTMLElement;
        this.prevPage = document.getElementById('btnRev') as HTMLElement;
        this.pageSize = document.getElementById('pageSize') as HTMLSelectElement;
        this.init();
    }
    static hidePopup() {
        const blanket = document.getElementById('blanket') as HTMLElement;
        blanket.style.display = 'none';
        const popup = document.getElementById('popup') as HTMLElement;
        popup.style.display = 'none';
        const confirm = document.getElementById('confirm') as HTMLElement;
        confirm.style.display = 'none';
    }
    static repositionPopup() {
        const confirm = document.getElementById('confirm') as HTMLElement;
        confirm.style.top = Math.max(0, (window.innerHeight - confirm.offsetHeight) / 2) + 'px';
        confirm.style.left = ((window.innerWidth - confirm.offsetWidth) / 2) + 'px';
        const popup = document.getElementById('popup') as HTMLElement;
        popup.style.top = Math.max(0, (window.innerHeight - popup.offsetHeight) / 2) + 'px';
        popup.style.left = ((window.innerWidth - popup.offsetWidth) / 2) + 'px';
    }
    static async deleteIt(item: string) {

        try {
            const response = await fetch(`http://localhost:8080/api/rating/${item}`, {
                method: 'DELETE', // HTTP method
                mode: "cors",
                headers: {
                    'Content-Type': 'application/json', // Sending JSON
                    'Accept': 'application/json'        // Expecting JSON back
                }
            });

            // Check if the response is OK (status in the range 200–299)
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
        } catch (error) {
            console.error((error as Error).stack);
            alert("Unable to delete rating");
        } finally {
            const yesBtn = document.getElementById('confirmYes') as HTMLButtonElement;
            yesBtn.onclick = null;
            const noBtn = document.getElementById('confirmNo') as HTMLButtonElement;
            noBtn.onclick = null;

            PlayerRating.hidePopup();
        }
    }
    static okay() {
        const confirmationString = document.getElementById('deletion') as HTMLElement;
        try {
            const foundElement = document.querySelector(`[data-id = "${confirmationString.innerText}"]`);
            const parent = foundElement?.parentNode;
            const grandparent = parent?.parentNode;
            if (grandparent && grandparent.parentNode) {
                grandparent.parentNode.removeChild(grandparent);
            }
        } catch (error) {
            console.error((error as Error).cause);
        } finally {
            PlayerRating.deleteIt(confirmationString.innerText);

        }
    }
    static notOkay() {
        const yesBtn = document.getElementById('confirmYes') as HTMLButtonElement;
        yesBtn.onclick = null;
        const noBtn = document.getElementById('confirmNo') as HTMLButtonElement;
        noBtn.onclick = null;
        PlayerRating.hidePopup();
    }
    static confirm() {
        const element = (this as unknown as HTMLElement).dataset.id;
        const blanket = document.getElementById('blanket') as HTMLElement;
        blanket.style.display = '';
        const confirm = document.getElementById('confirm') as HTMLElement;
        confirm.style.display = '';
        const confirmationString = document.getElementById('deletion') as HTMLElement;
        confirmationString.innerText = `${element}`;
        const yesBtn = document.getElementById('confirmYes') as HTMLButtonElement;
        yesBtn.onclick = PlayerRating.okay;
        const noBtn = document.getElementById('confirmNo') as HTMLButtonElement;
        noBtn.onclick = PlayerRating.notOkay;
    }
    static async populate() {
        const element = (this as unknown as HTMLElement).dataset.id;
        const blanket = document.getElementById('blanket') as HTMLElement;
        blanket.style.display = '';
        const popup = document.getElementById('popup') as HTMLElement;
        popup.style.display = '';
        let data;
        try {
            const form = document.getElementById('playerForm') as HTMLFormElement | null;
            const response = await fetch(`http://localhost:8080/api/rating/${element}`, {
                method: 'GET', // HTTP method
                mode: "cors",
                headers: {
                    'Content-Type': 'application/json', // Sending JSON
                    'Accept': 'application/json'        // Expecting JSON back
                }
            });

            // Check if the response is OK (status in the range 200–299)
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            data = await response.json();
            const tempRating: RatingAPIType = data.data;
            Object.entries(tempRating).forEach(([key, value]) => {
                const field = form?.elements.namedItem(key) as HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement | null;
                if (!field) {
                    return;
                }
                if (field instanceof HTMLInputElement) {
                    if (field.type === 'text') {
                        field.value = String(value);
                    } else if (field.type === 'number') {
                        field.value = String(value);
                    } else if (field.type === 'checkbox') {
                        field.checked = Boolean(value);
                    } else {
                        field.value = String(value);
                    }
                } else if (field instanceof HTMLSelectElement || field instanceof HTMLTextAreaElement) {
                    field.value = String(value);
                }
            })
            const id = form?.elements.namedItem('ratingID') as HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement | null;
            id!.value = String(element);
            const button = document.getElementById('playerFormAct') as HTMLButtonElement;
            button.innerText = "Submit";
        } catch (error) {
            console.error((error as Error).stack);
        }
    }
    static changeRow(){
        const rating: RatingAPIType =
        {
            qb_name_f: (document.getElementById('qb_name_f') as HTMLInputElement).value as string,
            qb_name_l: (document.getElementById('qb_name_l') as HTMLInputElement).value as string,
            team: (document.getElementById('team') as HTMLInputElement).value as string,
            attempts: Number.parseInt((document.getElementById('attempts') as HTMLInputElement).value as string),
            completions: Number.parseInt((document.getElementById('completions') as HTMLInputElement).value as string),
            yards: Number.parseInt((document.getElementById('yards') as HTMLInputElement).value as string),
            touchdowns: Number.parseInt((document.getElementById('touchdowns') as HTMLInputElement).value as string),
            interceptions: Number.parseInt((document.getElementById('interceptions') as HTMLInputElement).value as string)
        };
        const ratingID = (document.getElementById('ratingID') as HTMLInputElement).value as string;
        rating.id = Number(ratingID);
        const foundElement = document.querySelector(`[data-id = "${ratingID}"]`);
        const parent = foundElement?.parentNode;
        const grandparent = parent?.parentNode;
        const name = grandparent?.firstChild as HTMLTableCellElement;
        const team = name?.nextSibling as HTMLTableCellElement;
        const qbr = team?.nextSibling as HTMLTableCellElement;
        const qbrNode = Array.from(qbr.childNodes).find(
            node => node.nodeType === Node.TEXT_NODE && node.textContent?.trim() !== ""
        )
        qbrNode!.textContent = `${PlayerRating.calculateRating(
            rating.attempts,
            rating.completions,
            rating.yards,
            rating.touchdowns,
            rating.interceptions
        )}`
        name.textContent = `${rating.qb_name_f} ${rating.qb_name_l}`;
        team.textContent = rating.team;
        PlayerRating.putData(`http://localhost:8080/api/rating/${ratingID}`, rating);
    }
    static addRow(data: RatingAPIType) {
        const dataTable = document.getElementById('data') as HTMLTableElement;
        const elTr = document.createElement('tr');
        const elName = document.createElement('td');
        const elTeam = document.createElement('td');
        const elQBR = document.createElement('td');

        const elTextName = document.createTextNode(`${data.qb_name_f} ${data.qb_name_l}`);
        elName.appendChild(elTextName);

        const elTextTeam = document.createTextNode(`${data.team}`);
        elTeam.appendChild(elTextTeam);

        const elTextQBR = document.createTextNode(
            PlayerRating.calculateRating(
                data.attempts,
                data.completions,
                data.yards,
                data.touchdowns,
                data.interceptions
            ));

        const elEdit = document.createElement('span');
        //const elEditDataId = document.createAttribute('data-id')
        elEdit.dataset.id = (data.id?.toString() || "0");
        //elEdit.appendChild(elEditDataId);
        elEdit.classList.add('control', 'edit');
        elEdit.onclick = PlayerRating.populate;
        const elEditText = document.createTextNode('e')
        elEdit.appendChild(elEditText);

        const elDelete = document.createElement('span');
        //const elDeleteDataId = document.createAttribute('data-id')
        elDelete.dataset.id = (data.id?.toString() || "0");
        elDelete.classList.add('control', 'delete');
        elDelete.onclick = PlayerRating.confirm;
        //elDelete.appendChild(elDeleteDataId);
        const elDeleteText = document.createTextNode('d')
        elDelete.appendChild(elDeleteText);

        elQBR.appendChild(elTextQBR);
        elQBR.appendChild(elDelete);
        elQBR.appendChild(elEdit);
        elTr.appendChild(elName);
        elTr.appendChild(elTeam);
        elTr.appendChild(elQBR);
        dataTable.appendChild(elTr);
    }
    static calculateRating(attempts: number, completions: number, yards: number, touchdowns: number, interceptions: number): string {
        const compPerAtt = ((completions / attempts) - 0.3) * 5;
        const yardsPerAtt = ((yards / attempts) - 3) * 0.25;
        const tdsPerAtt = (touchdowns / attempts) * 20;
        const intsPerAtt = 2.375 - (interceptions / attempts * 25);
        const rating = (((((PlayerRating.minMax(compPerAtt)) + PlayerRating.minMax(yardsPerAtt)) + PlayerRating.minMax(tdsPerAtt) + PlayerRating.minMax(intsPerAtt)) / 6) * 100)
        return rating.toFixed(2);
    }
    static minMax(x: number) {
        return Math.max(0, Math.min(x, 2.375))
    }
    private addRecord() {
        const blanket = document.getElementById('blanket') as HTMLElement;
        blanket.style.display = '';
        const popup = document.getElementById('popup') as HTMLElement;
        popup.style.display = '';
        const playerForm = document.getElementById('playerForm') as HTMLFormElement;
        if (playerForm) {
            playerForm.reset();
        }
        const button = document.getElementById('playerFormAct') as HTMLButtonElement;
        button.innerText = "Add";

        PlayerRating.repositionPopup();
    }
    private async formAction() {

        const rating: RatingAPIType =
        {
            qb_name_f: (document.getElementById('qb_name_f') as HTMLInputElement).value as string,
            qb_name_l: (document.getElementById('qb_name_l') as HTMLInputElement).value as string,
            team: (document.getElementById('team') as HTMLInputElement).value as string,
            attempts: Number.parseInt((document.getElementById('attempts') as HTMLInputElement).value as string),
            completions: Number.parseInt((document.getElementById('completions') as HTMLInputElement).value as string),
            yards: Number.parseInt((document.getElementById('yards') as HTMLInputElement).value as string),
            touchdowns: Number.parseInt((document.getElementById('touchdowns') as HTMLInputElement).value as string),
            interceptions: Number.parseInt((document.getElementById('interceptions') as HTMLInputElement).value as string)
        };
        const typeAddOrSubmit = (this as unknown as HTMLButtonElement);
        if(typeAddOrSubmit.innerText === 'Add'){
            const savedRating = await PlayerRating.postData('http://localhost:8080/api/rating', rating);
            PlayerRating.addRow(savedRating.data);
        }else if(typeAddOrSubmit.innerText === 'Submit'){
            PlayerRating.changeRow();
        }
    }
    static async fillTable() {
        let pageSize = 0;
        const selectElement = document.getElementById('pageSize') as HTMLSelectElement;
        const selectedIndex: number = selectElement.selectedIndex;
        const selectOptions = selectElement.options as HTMLOptionsCollection;
        if (selectOptions && selectOptions && (selectedIndex >= 0)) {
            // const selectedValue: string = selectElement.value; // Value attribute of the selected option
            const selectedText =
                (selectOptions instanceof HTMLOptionsCollection) &&
                (selectOptions !== undefined) &&
                (selectedIndex >= 0)
                    ? selectOptions[selectedIndex]?.textContent//selectOptions[ selectedIndex ].text
                    : "" as string; // Visible text
            pageSize = Number(selectedText);
        } else {
            console.warn("No option selected.");
        }

        const pageNo = Number((document.getElementById('paging') as HTMLElement).textContent);
        const count = await PlayerRating.countRatings();
        if(pageNo > 1){
            document.getElementById('btnRev')?.classList.remove('disabled');
        }else{
            document.getElementById('btnRev')?.classList.add('disabled');
        }
        if(count <= (pageNo * pageSize)){
            document.getElementById('btnFwd')?.classList.add('disabled');
        }else if(count > pageSize || pageNo < (pageSize / count)){
            document.getElementById('btnFwd')?.classList.remove('disabled');
        }
        const ratings = await PlayerRating.getData(pageNo-1, pageSize);
        for (const i of ratings) {
            PlayerRating.addRow(i);
        }

    }
    static async countRatings(){
        const response = await fetch(`http://localhost:8080/api/ratings`, {
                method: 'OPTIONS', // HTTP method
                mode: "cors",
                headers: {
                    'Content-Type': 'application/json', // Sending JSON
                    'Accept': '*/*'        // Expecting JSON back
                }
        });
        const body = await response.json();
        if(response.ok && body.data.count){
            return body.data.count;
        }
        return 0;
    }
    /**
     * getData
     */
    static async getData(page=0, pagesize=5) {
        const response = await fetch(`http://localhost:8080/api/ratings?page=${page}&pagesize=${pagesize}`);
        const body = await response.json();
        if (response.ok && body.data){
            return (body.data.ratings);
        }
        return null
    }
    /**
     * postData
     */
    static async postData(url = '', data = {}) {
        try {
            const response = await fetch(url, {
                method: 'POST', // HTTP method
                mode: "cors",
                headers: {
                    'Content-Type': 'application/json', // Sending JSON
                    'Accept': '*/*'        // Expecting JSON back
                },
                body: JSON.stringify(data) // Convert object to JSON string
            });

            // Check if the response is OK (status in the range 200–299)
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }

            // Parse and return JSON response
            return await response.json();
        } catch (error) {
            console.error((error as Error).stack);
            alert("Unable to send data");
        } finally {
            PlayerRating.hidePopup();
        }
    }
    static async putData(url = '', data = {}){
        try {
            const response = await fetch(url, {
                method: 'PUT', // HTTP method
                mode: "cors",
                headers: {
                    'Content-Type': 'application/json', // Sending JSON
                    'Accept': '*/*'        // Expecting JSON back
                },
                body: JSON.stringify(data) // Convert object to JSON string
            });

            // Check if the response is OK (status in the range 200–299)
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
        } catch (error) {
            console.error((error as Error).stack);
        } finally {
            PlayerRating.hidePopup();
        }
    }
    static updateTable(){
        const pageNo = Number((document.getElementById('paging') as HTMLElement).textContent);
        if(this instanceof HTMLElement && !this.classList.contains('disabled')){
            if(this.classList.contains('forward') && !this.classList.contains('disabled')){
                (document.getElementById('paging') as HTMLElement).textContent = String(pageNo+1);
            }
            if(this.classList.contains('back') && !this.classList.contains('disabled')){
                (document.getElementById('paging') as HTMLElement).textContent = String(pageNo-1)
            }
        }else if(this instanceof HTMLSelectElement){
            console.log(this)
        }
        const data = document.getElementById('data') as HTMLTableElement;
        while(data.firstChild){
            data.removeChild(data.firstChild);
        }
        PlayerRating.fillTable();
    }
    private init() {
        PlayerRating.hidePopup();
        const blanket = document.getElementById('blanket') as HTMLElement;
        blanket.onclick = PlayerRating.hidePopup;
        window.onresize = PlayerRating.repositionPopup;
        PlayerRating.fillTable();
        this.playerFormClose.onclick = PlayerRating.hidePopup;
        this.addRating.onclick = this.addRecord;
        this.playerFormAction.onclick = this.formAction;
        this.nextPage.onclick = PlayerRating.updateTable;
        this.prevPage.onclick = PlayerRating.updateTable;
        this.pageSize.onchange = PlayerRating.updateTable;
    }

}
(() => {
    ScrollbarHandler.registerCenteredElement(document.getElementById('root') as HTMLElement);

    const ck = new AntiPollution();
    ck.namespace(["rating"]);
    new PlayerRating();

})()
