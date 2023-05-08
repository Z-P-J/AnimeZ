import hilog from '@ohos.hilog'

const DOMAIN: number = 0xFF00
const PREFIX: string = '[AnimeZ]'
const FORMAT: string = '%{public}s, %{public}s'

export default class Logger {


    static d(tag: any, ...args: string[]) {
        hilog.debug(DOMAIN, PREFIX, FORMAT, this.wrapArgs(tag, args))
    }

    static i(tag: any, ...args: string[]) {
        hilog.info(DOMAIN, PREFIX, FORMAT, this.wrapArgs(tag, args))
    }

    static w(tag: any, ...args: string[]) {
        hilog.warn(DOMAIN, PREFIX, FORMAT, this.wrapArgs(tag, args))
    }

    static e(tag: any, ...args: string[]) {
        hilog.error(DOMAIN, PREFIX, FORMAT, this.wrapArgs(tag, args))
    }

    static wrapArgs(tag: any, args: string[]): string[] {
        let name: string;
        if (tag instanceof Object) {
            name = tag.constructor.name;
        } else if (tag instanceof Function) {
            name = tag.toString();
        } else {
            name = '' + tag;
        }
        if (name) {
            if (args) {
                args.splice(0, 0, name);
            } else {
                args = [name];
            }
        }
        return args;
    }

}