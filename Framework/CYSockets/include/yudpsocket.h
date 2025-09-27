//
//  yudpsocket.h
//  SwiftOSC
//
//  Created by Frans-Jan Wind on 27/09/2025.
//


#ifndef YUDPSOCKET_H
#define YUDPSOCKET_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif

int yudpsocket_server(const char *host, int port);
int yudpsocket_recvv(int sockfd, char *buf, int len, int timeout_ms);

#ifdef __cplusplus
}
#endif
#endif /* YUDPSOCKET_H */
