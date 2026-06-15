export class AntiPollution {
    private calebking;
    constructor() {
        if (this.calebking === "undefined") {
            this.calebking = {};
        }
        this.namespace(["rating"]);
    }
    /**
     * namespace
     */
    public namespace(argv: Array<string>) {
        const args = argv;
        const obj = new Map<string, object>();
        let arr: Array<string>;
        for (const element of args) {
            arr = ("" + element).split("."); //split the args
            obj.set("calebking", {});

            for (let j = (arr[0] === "calebking") ? 1 : 0; j < arr.length; j = j + 1) {
                obj.set(arr[j] as string, {});
                //obj = obj[arr[j]];
            }
        }
        this.calebking =  obj;
    }
    /**
     * assert
     */
    public assert(shouldBeTrue: boolean) {
        if(shouldBeTrue !== true){
            try {
                throw new Error("False condition");
            } catch (e) {
                const frames:Array<string>|undefined = (e as Error).stack?.split("@");
                frames?.shift();
                frames?.shift();
                throw new Error(`assert failed\n ${frames?.join("\n")}`, { cause: e });
            }
        }
    }
}
