import { Downloader } from './Downloader';
import Logger from '../utils/Logger'
import Globals from '../utils/Globals'

/**
 * ZDownloader，管理所有下载器
 * @author Z-P-J
 */
export class ZDownloader {

    /**
     * 根据下载器的类创建或获取全局唯一的下载器
     * @param clazz
     */
    static get<T extends Downloader>(clazz: { new(): T }): T {
        Logger.e(this, 'get clazz type=' + (typeof clazz))
        return Globals.getOrCreate('downloader_' + clazz.name, () => {
            return new clazz();
        })
    }
}