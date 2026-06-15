export interface RatingAPIType{
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
