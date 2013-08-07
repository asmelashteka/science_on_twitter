echo "Computing nof conf. retweeted"
time code/network_features.py $retweet_network $conf_ids > __nof.confs.retweeted
echo "Done!"
echo "Computing nof confs mentioned"
time code/network_features.py $mention_network $conf_ids > __nof.confs.mentioned
echo "Done"
echo "Computing nof conf. friends"
time code/network_features.py $friend_network $conf_ids > __nof_conf.friends
echo "Done!"

