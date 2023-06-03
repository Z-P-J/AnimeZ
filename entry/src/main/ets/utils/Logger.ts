import hilog from '@ohos.hilog'

const DOMAIN: number = 0xFF00
const PREFIX: string = '[AnimeZ]'
const FORMAT: string = '%{public}s, %{public}s'

/**
 * 日志工具类
 */
export default class Logger {

    /**
     * debug
     */
    static d(tag: any, ...args: string[]) {
        hilog.debug(DOMAIN, PREFIX, FORMAT, this.wrapArgs(tag, args))
    }

    /**
     * info
     */
    static i(tag: any, ...args: string[]) {
        hilog.info(DOMAIN, PREFIX, FORMAT, this.wrapArgs(tag, args))
    }

    /**
     * warn
     */
    static w(tag: any, ...args: string[]) {
        hilog.warn(DOMAIN, PREFIX, FORMAT, this.wrapArgs(tag, args))
    }

    /**
     * error
     */
    static e(tag: any, ...args: string[]) {
        hilog.error(DOMAIN, PREFIX, FORMAT, this.wrapArgs(tag, args))
    }

    /**
     * 将tag转换为字符串
     * 1、如果tag是Object类型，转换为获取构造方法名称
     * 2、如实是Function类型，调用toString
     * 3、其他类型，type+tag拼接
     */
    static wrapArgs(tag: any, args: string[]): string[] {
        let name: string;
        if (tag instanceof Object) {
            name = tag.constructor.name;
        } else if (tag instanceof Function) {
            name = tag.toString();
        } else {
            name = (typeof tag) + '-' + tag;
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