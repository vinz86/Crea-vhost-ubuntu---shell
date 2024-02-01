  echo
  echo -n "# Procedo con la creazione di un nuovo vhost? [s]/n: "
  read CONFIRM
  if [[ ${CONFIRM} = "s" || ${CONFIRM} = "y" || $CONFIRM = "" ]]; then

    cd '/var/www'

    echo -n "- Inserisci il nome del dominio: "
    read NOME_DOMINIO
    echo 
    echo "Procedo alla creazione del vhost ${NOME_DOMINIO}..."

    echo
    echo "~Creo la directory /var/www/${NOME_DOMINIO}/public_html/ e assegno i giusti permessi all'utente ${USER}" 
    sudo mkdir -p "/var/www/${NOME_DOMINIO}/public_html/"
    sudo chown -R $USER:$USER "/var/www/${NOME_DOMINIO}/public_html"
    sudo chmod -R 755 "/var/www/${NOME_DOMINIO}"

    echo -n "~Creo la index.html con il seguente contenuto: "
    sudo touch "/var/www/${NOME_DOMINIO}/public_html/index.html"
    echo "It works: ${NOME_DOMINIO}"| sudo tee /var/www/${NOME_DOMINIO}/public_html/index.html

    SITECONFIG="/etc/apache2/sites-available/${NOME_DOMINIO}.conf"

    echo "~Creo il file ${SITECONFIG} con il seguente contenuto: "
    sudo touch ${SITECONFIG}
    echo "<VirtualHost *:80>" | sudo tee $SITECONFIG
    echo "ServerAdmin admin@${NOME_DOMINIO}" | sudo tee -a $SITECONFIG
    echo "    ServerName ${NOME_DOMINIO}" | sudo tee -a $SITECONFIG
    echo "    ServerAlias www.${NOME_DOMINIO}" | sudo tee -a $SITECONFIG
    echo "" | sudo tee -a $SITECONFIG
    echo "    DocumentRoot /var/www/${NOME_DOMINIO}/public_html" | sudo tee -a $SITECONFIG
    echo "" | sudo tee -a $SITECONFIG
    echo "    ErrorLog ${APACHE_LOG_DIR}/${NOME_DOMINIO}.error.log" | sudo tee -a $SITECONFIG
    echo "    CustomLog ${APACHE_LOG_DIR}/${NOME_DOMINIO}.access.log combined" | sudo tee -a $SITECONFIG
    echo "</VirtualHost>" | sudo tee -a $SITECONFIG

    echo
    echo "~Testo la configurazione: "
    sudo apache2ctl configtest

    echo "~Abilito il sito:"
    sudo a2ensite ${NOME_DOMINIO}

    echo "~Disabilito configurazione di default:"
    sudo a2dissite 000-default.conf

    echo "~Riavvio apache"
    sudo systemctl restart apache2

    echo
    echo -n "# Procedo con l'aggiunta del dominio in /etc/hosts? [s]/n:"
    read CONFIRM
    if [[ ${CONFIRM} = "s" || ${CONFIRM} = "y" || $CONFIRM = "" ]]; then

        echo -n "-Inserisci l'indirizzo ip (default 127.0.0.1): "
        read INDIRIZZO_IP

        echo "~Aggiungo la riga seguente in /etc/hosts e riavvio apache:"
        if [[ ${INDIRIZZO_IP} == "" ]]; then
            echo "127.0.0.1         ${NOME_DOMINIO}" | sudo tee -a /etc/hosts
        else
            echo "${INDIRIZZO_IP}         ${NOME_DOMINIO}" | sudo tee -a /etc/hosts
        fi
        
        sudo systemctl restart apache2
    fi

    echo
    echo "###################################################"
    echo "* vhost per ${NOME_DOMINIO}: ${SITECONFIG} creato."
    echo "* La document root è: /var/www/${NOME_DOMINIO}/html"
    echo
    echo "* Apri l'url http://${NOME_DOMINIO}"
    echo "###################################################"

else
    echo "###############################"
    echo "* Creazione vhost non eseguita."
    echo "###############################"
fi
  
