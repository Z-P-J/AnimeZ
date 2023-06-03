import { MimeTypeMap } from './MimeTypes'

const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

const CONTENT_DISPOSITION_PATTERN = new RegExp("attachment;\\s*filename\\s*=\\s*(\"?)([^\"]*)\\1\\s*$");

/**
 * 下载工具类
 * @author Z-P-J
 */
export class DownloadUtils {
    private constructor() {
    }

    /**
     * 格式化文件大小
     * @param bytes
     */
    static formatFileSize(bytes: number): string {

        let size = bytes;
        let unitIndex = 0;

        while (size >= 1024 && unitIndex < units.length - 1) {
            size /= 1024;
            unitIndex++;
        }

        // 保留两位小数，四舍五入
        size = Math.round(size * 100) / 100;
        return `${size} ${units[unitIndex]}`;
    }

    /**
     * 格式化下载进度
     * @param progress
     */
    static formatProgress(progress: number) {
        return `${Math.round(progress)} %`;
    }

    /**
     * 获取下载任务文件名
     * @param url
     * @param contentDisposition
     * @param mimeType
     */
    static guessFileName(url: string, contentDisposition?: string, mimeType?: string): string {

        let fileName;
        if (contentDisposition) {
            fileName = DownloadUtils.parseContentDisposition(contentDisposition);
            if (fileName) {
                let index = fileName.lastIndexOf('/') + 1;
                if (index > 0) {
                    fileName = fileName.substring(index);
                }
            }
        }

        if (!fileName) {
            let decodedUrl = decodeURI(url);
            if (decodedUrl) {
                let queryIndex = decodedUrl.indexOf('?');
                if (queryIndex > 0) {
                    decodedUrl = decodedUrl.substring(0, queryIndex);
                }
                if (!decodedUrl.endsWith("/")) {
                    let index = decodedUrl.lastIndexOf('/') + 1;
                    if (index > 0) {
                        fileName = decodedUrl.substring(index);
                    }
                }
            }
        }

        if (!fileName) {
            // TODO
            return null
            //            fileName = 'Unknown-File';
        }

        let extension;

        let dotIndex = fileName.indexOf('.');
        if (dotIndex < 0) {
            if (mimeType) {
                extension = MimeTypeMap.getExtensionFromMimeType(mimeType);
                if (!extension) {
                    extension = "." + extension;
                }
            }
            if (!extension) {
                if (mimeType && mimeType.toLowerCase().startsWith("text/")) {
                    if (mimeType.toLowerCase() == "text/html") {
                        extension = ".html";
                    } else {
                        extension = ".txt";
                    }
                } else {
                    extension = ".bin";
                }
            }
        } else {
            if (mimeType) {
                let lastDotIndex = fileName.lastIndexOf('.');

                let ext: string = fileName.substring(lastDotIndex + 1);

                let extensions = MimeTypeMap.getExtensions(mimeType);
                if (extensions) {
                    if (extensions.indexOf(ext.toLowerCase()) >= 0) {
                        extension = "." + ext;
                    } else {
                        let typeFromExt = MimeTypeMap.getMimeTypeFromExtension(ext);
                        if (typeFromExt && typeFromExt.toLowerCase() != mimeType) {
                            extension = extensions[0];
                            if (extension) {
                                extension = "." + extension;
                            }
                        }
                    }
                }
            }
            if (!extension) {
                extension = fileName.substring(dotIndex);
            }
            fileName = fileName.substring(0, dotIndex);
        }

        return fileName + extension;
    }

    /**
     * 从content-disposition中解析文件名
     * @param contentDisposition
     */
    static parseContentDisposition(contentDisposition: string) {
        let result = CONTENT_DISPOSITION_PATTERN.exec(contentDisposition);
        return result[2];
    }
}