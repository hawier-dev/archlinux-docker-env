FROM archlinux:latest
LABEL maintainer="Mikołaj Badyl <contact@hawier.dev>"

ARG username=hawierdev
ARG UID=1053372

# Updating the system
RUN pacman -Sy archlinux-keyring --noconfirm
RUN pacman-key --init
RUN pacman-key --populate archlinux
RUN pacman-key --refresh-keys
RUN pacman -Syu --noconfirm sudo git fish gd lib32-gcc-libs python wget base-devel

# Add a user
RUN useradd -u $UID --create-home $username
RUN echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install aur
RUN git clone https://aur.archlinux.org/yay.git /home/$username/yay
RUN chown -R $username /home/$username/yay 
RUN su -c "cd /home/$username/yay && makepkg -si --noconfirm" $username
RUN rm -rf /home/$username/yay

# Additions (optional)
RUN git clone https://github.com/dylanaraps/pfetch.git /home/$username/pfetch
RUN cd /home/$username/pfetch && make && make install
RUN rm -rf /home/$username/pfetch
RUN su -c "mkdir -p /home/$username/.config/fish" $username
RUN su -c "echo 'set -U fish_greeting' > /home/$username/.config/fish/config.fish" $username
RUN su -c "echo 'pfetch' > /home/$username/.config/fish/config.fish" $username

# Install miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_22.11.1-1-Linux-x86_64.sh
RUN chmod +x './Miniconda3-py310_22.11.1-1-Linux-x86_64.sh'
RUN su -c './Miniconda3-py310_22.11.1-1-Linux-x86_64.sh -b' $username
ENV PATH="$PATH:/home/$username/miniconda3/bin"
RUN conda init fish

USER $username
WORKDIR /home/hawierdev
ENV LANG=en_US.UTF-8
CMD ["/usr/bin/fish"]
