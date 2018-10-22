#!/usr/bin/env bash
get_amd_cards_temp(){
	echo $(jq -c "[.temp$amd_indexes_array]" <<< $gpu_stats)
}

get_amd_cards_fan(){
	echo $(jq -c "[.fan$amd_indexes_array]" <<< $gpu_stats)
}
gpu_detect_json=`gpu-detect listjson`
amd_indexes_array=`echo "$gpu_detect_json" | jq -c '[ . | to_entries[] | select(.value.brand == "amd") | .key ]'`
gpu_stats=`timeout -s9 60 gpu-stats`

temp=$(get_amd_cards_temp)
fan=$(get_amd_cards_fan)
stats_raw=`curl --connect-timeout 2 --max-time 5 --silent --noproxy '*' http://127.0.0.1:60050`

khs=`echo $stats_raw | jq -r '.hashrate.total[0]'`
stats=`echo $stats_raw | jq '{hs: [.hashrate.threads[][0]], hs_units: "khs", temp: '$temp', fan: '$fan', uptime: .uptime, ar: [.results.shares_good, .results.shares_total - .results.shares_good], algo: .algo}'`

#echo $khs
#echo $stats
#echo $temp