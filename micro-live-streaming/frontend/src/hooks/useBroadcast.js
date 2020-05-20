import React, { useState, useEffect, useCallback, useMemo, useRef } from 'react';
import { getLive } from '../service/Api';
import io from "socket.io-client";
import Peer from "peerjs";

const useBroadcast = (data) => {

  const { start, stop, liveSlug, password, videoRef } = data;

  const [error, setError] = useState('');
  const [usersConnected, setUserConnected] = useState(0);
  const [live, setLive] = useState({});
  const peerRef = useRef();
  const streamRef = useRef();

  const socket = useMemo(() => {
    if (!start) { return null; }
    return io(`${process.env.REACT_APP_MICRO_BACKEND_MANAGER_URL}/live`);
  }, [start]);

  useEffect(() => {

    if (error) { return }

    const load = async () => {
      try {
        setLive(await getLive(liveSlug));
      } catch (error) {
        console.log(error);
        setError(error)
      }
    }
    load();
  }, [liveSlug, error]);
  
  useEffect(() => {

    if (!socket) { return; }

    socket.on('connect', () => {

      socket.emit('join', {slug: liveSlug, password: password});

      socket.on('count-users', (count) => {
        setUserConnected(count);
      });
    });

  }, [liveSlug, socket]);

  useEffect(() => {

    if (!streamRef || !start || !socket || !peerRef.current) { return }

    console.log('Initialized peer connection...');

    peerRef.current = new Peer({
      host: process.env.REACT_APP_MICRO_GENERATOR_PEER_DOMAIN,
      port: parseInt(process.env.REACT_APP_MICRO_GENERATOR_PEER_PORT)
    });

    peerRef.current.on('open', (peer_id) => {
      console.log('BoradcastPeer id: ', peer_id);
      socket.emit('set-broadcaster', {client_id: peer_id, password: password});
    });
  });

  return { usersConnected }
}

export default useBroadcast;
