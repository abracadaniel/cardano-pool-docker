function check_balance {
    PRICE=$1
    MINIMAL_LOVELACE_REMAINING_ON_UTXO=1000000
    LOVELACE_FOR_UTXO_TXIX=10000000000000

    if [ -z "$COLD_CREATE" ]; then
        while true; do
            echo ""
            echo "Checking balance for address ${ADDRESS}."
            echo ""

            TOTAL_LOVELACE=0
            cardano-cli query utxo ${NETWORK_ARGUMENT} --address ${ADDRESS}

            UTXOS=$(cardano-cli query utxo ${NETWORK_ARGUMENT} --address ${ADDRESS} | tail -n +3)
            echo "UTXO#TXIX: LOVELACE"
            while IFS= read -r line ; do
                arr=(${line})
                LOVELACE=${arr[2]}
                TOTAL_LOVELACE=$(expr ${TOTAL_LOVELACE} + ${LOVELACE})

                if [ -n "${LOVELACE}" ]; then
                    echo "${arr[0]}#${arr[1]}: ${arr[2]}"
                    REMAINING=$(expr ${LOVELACE} - ${PRICE})
                    if [ "$LOVELACE" -ge "$PRICE" ] && [ "$LOVELACE_FOR_UTXO_TXIX" -ge "$LOVELACE" ] && [ "$REMAINING" -ge "$MINIMAL_LOVELACE_REMAINING_ON_UTXO" ]; then
                        UTXO=${arr[0]}
                        TXIX=${arr[1]}
                        LOVELACE_FOR_UTXO_TXIX=$LOVELACE
                    fi
                fi
            done <<< "${UTXOS}"

            if [ -n "${UTXO}" ]; then
                LOVELACE=$LOVELACE_FOR_UTXO_TXIX
                echo "Address is successfully funded."
                echo ""
                echo "Got UTXO"
                echo "UTXO: ${UTXO}#${TXIX}"
                echo "Lovelace Holding: ${LOVELACE}"
                break
            fi

            echo "You need to fund your address with atleast ${PRICE} Lovelace to continue with the transaction."
            echo "Your payment address is:"
            echo "${ADDRESS}"
            echo ""
            echo "If you have funded your address, you need to wait for the transaction to be processed and your node to synchronize."
            sync_status
            echo ""

            sleep 10
        done
    else
        echo "Find UTXO and TXIX containing atleast ${PRICE} Lovelace for address ${ADDRESS} (Wallet ${WALLET})"
        echo "Run \`cardano-cli query utxo ${NETWORK_ARGUMENT} --address ${ADDRESS}\`, on online node to find the values."
        read -p "Enter the UTXO: " UTXO
        read -p "Enter the TXIX: " TXIX
        LOVELACE=0
    fi
}

