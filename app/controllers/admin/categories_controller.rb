class Admin::CategoriesController < Admin::BaseController
  layout 'administration'

  cache_sweeper :blog_sweeper

  def index; redirect_to :action => 'new' ; end
  def edit; new_or_edit;  end

  def new 
    respond_to do |format|
      format.html { new_or_edit }
      format.js { 
        @category = Category.new
      }
    end
  end

  def destroy
    @category = Category.find(params[:id])
    if request.post?
      @category.destroy
      redirect_to :action => 'index'
    end
  end

  def order
    Category.reorder(params[:category_list])
    render :nothing => true
  end

  def asort
    Category.reorder_alpha
    category_container
  end

  def category_container
    @categories = Category.find(:all, :order => :position)
    render :partial => "categories"
  end

  def reorder
    @categories = Category.find(:all, :order => :position)
    render :layout => false
  end

  private

  def new_or_edit
    @categories = Category.find(:all)
    @category = case params[:id]
                when nil
                  Category.new
                else
                  Category.find(params[:id])
                end
    @category.attributes = params[:category]
    if request.post?
      respond_to do |format|
        format.html { save_category }
        format.js do 
          @category.save
          @article = Article.new
          @article.categories << @category
          return render(:partial => 'admin/content/categories')
        end
      end
      return
    end
    render 'new'
  end

  def save_category
    if @category.save!
      flash[:notice] = _('Category was successfully saved.')
    else
      flash[:error] = _('Category could not be saved.')
    end
    redirect_to :action => 'index'
  end

end
