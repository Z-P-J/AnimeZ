

export interface VideoHistoryInfo {

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

    key: string;
    episodeListIndex: number;
    episodeIndex: number;
    url: string;
    title: string;
    lastTime: number;
    coverUrl: string;
    videoProgress: number;

}