/**
 * 视频历史记录
 * TODO 支持数据源key和数据源title
 */
export class VideoHistoryInfo {

    link: string

//    @Columns({columnName: 'title', types: ColumnType.str })
    title: string

    totalTime: number

//    @Columns({columnName: 'lastTime', types: ColumnType.num })
    currentTime: number

//    @Columns({columnName: 'coverUrl', types: ColumnType.str })
    coverUrl: string

//    @Columns({columnName: 'episodeListIndex', types: ColumnType.num })
    episodeListIndex: number

//    @Columns({columnName: 'episodeIndex', types: ColumnType.num })
    episodeIndex: number

//    @Columns({columnName: 'episodeName', types: ColumnType.str })
    episodeName: string

//    @Columns({columnName: 'videoUrl', types: ColumnType.str })
    videoUrl: string

//    @Columns({columnName: 'videoProgress', types: ColumnType.num })
    videoProgress: number

    sourceKey: string

    accessTime?: number

    static createByLink(sourceKey, link): VideoHistoryInfo {
        return {
            link: link,
            title: '',
            currentTime: 0,
            totalTime: 0,
            coverUrl: '',
            episodeListIndex: 0,
            episodeIndex: 0,
            episodeName: '',
            videoUrl: '',
            videoProgress: 0,
            sourceKey: sourceKey,
            accessTime: 0
        }
    }

}