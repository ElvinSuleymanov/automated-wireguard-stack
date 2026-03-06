graph TD

%% Clients
subgraph Clients
    RC[Remote Client]
    SS[Setup Script / Client Generator]
end

%% Cloud Infrastructure
subgraph AWS["AWS Cloud - Docker Stack"]

    %% Access Layer
    subgraph Access_Layer
        RP[Nginx Reverse Proxy]
        AS[Authentication Service]
    end

    %% VPN Layer
    subgraph VPN_Layer
        WG[WireGuard Server]
    end

    %% DNS Stack
    subgraph DNS_Stack
        PH[Pi-hole Ad Blocker]
        UB[Unbound Recursive Resolver]
    end

end

%% External Flow
RC -->|WireGuard Tunnel| WG
SS -->|API Request| RP
RP -->|Token Validation| AS

%% Internal DNS Flow
WG --> PH
PH --> UB

%% Internet Resolution
UB -->|Recursive DNS| ROOT[(Root DNS Servers)]

%% Styling
style WG fill:#1f77b4,color:#fff
style PH fill:#d62728,color:#fff
style UB fill:#2ca02c,color:#fff
style AS fill:#ff7f0e,color:#fff