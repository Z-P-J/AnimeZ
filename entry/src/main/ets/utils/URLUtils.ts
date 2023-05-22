export class URLUtils {

    private constructor() {
    }

    public static guessFileName(url: string, contentDisposition?: string, mimeType?: string): string {
        return 'downloadFile.temp';
    }

}