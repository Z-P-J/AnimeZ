

export class VideoHistoryInfo {

//    @PrimaryKey
//    private String key;
//    @Column(defaultValue = "0")
//    private int episodeListIndex;
//    @Column
//    private int position;
//    @Column
//    private String url;
//    @Column
//    private String title;
//    @Column
//    private String episode;
//    @Column
//    private long lastTime;
//    @Column
//    private String coverUrl;
//
//    @Column
//    private long videoProgress;

//    @Id()
//    @Unique()
//    @Columns({columnName: 'link', types: ColumnType.str })
    link: string;

//    @Columns({columnName: 'title', types: ColumnType.str })
    title: string;

//    @Columns({columnName: 'lastTime', types: ColumnType.num })
    lastTime: number;

//    @Columns({columnName: 'coverUrl', types: ColumnType.str })
    coverUrl: string;

//    @Columns({columnName: 'episodeListIndex', types: ColumnType.num })
    episodeListIndex: number;

//    @Columns({columnName: 'episodeIndex', types: ColumnType.num })
    episodeIndex: number;

//    @Columns({columnName: 'episodeName', types: ColumnType.str })
    episodeName: string;

//    @Columns({columnName: 'videoUrl', types: ColumnType.str })
    videoUrl: string;

//    @Columns({columnName: 'videoProgress', types: ColumnType.num })
    videoProgress: number;

}