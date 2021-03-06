class GossipsController < ApplicationController
  before_action :authenticate_user, only: [:create, :new]
  before_action :authenticate_author, only: [:destroy, :edit, :update]
  
  def index
    @all_gossips = Gossip.all
  end

  def show
    @gossip = Gossip.find(params["id"].to_i)
    @city = City.find(@gossip.user.city_id).name
  end

  def new
    @gossip = Gossip.new
  end

  def create
    @gossip = Gossip.new(content: params["content"], title: params["title"])
    @gossip.user = current_user
    if @gossip.save # essaie de sauvegarder en base @gossip
      flash[:notice] = "Bravo, votre potin est enregistré !" # affiche une alerte
      redirect_to gossips_path # si ça marche, il redirige vers la page d'index du site
    else # sinon, il render la view new
      render :new
      return
    end
  end

  def edit
    @gossip = Gossip.find(params[:id])
  end

  def update
    @gossip = Gossip.find(params[:id])
    @gossip.update(gossip_params)
    if @gossip.update(gossip_params)
      flash[:notice] = "Votre potin est mis à jour !"
      redirect_to gossips_path
    else
      render :edit
    end
  end

  def destroy
    @gossip = Gossip.find(params[:id])
    @gossip.destroy
    flash[:notice] = "Votre potin a disparu."
    redirect_to gossips_path
  end

  private

  def gossip_params
    params.require(:gossip).permit(:title, :content)
  end

  def authenticate_user
    unless current_user
      flash[:danger] = "Please log in."
      redirect_to new_session_path
    end
  end

  def authenticate_author
    @gossip = Gossip.find(params[:id])
    unless @gossip.user == current_user
      flash[:danger] = "You are not allowed to edit this gossip."
      redirect_to gossips_path
    end
  end
end
