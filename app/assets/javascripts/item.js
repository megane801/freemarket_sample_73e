$(document).on('turbolinks:load', ()=> {
  const buildFileField = (index)=> {
    const html = `<div dataindex="${index}" class="js-file_group">
                    <input class="main__content__img-up__file__l__field__file js-file" type="file"
                    name="item[images_attributes][${index}][url]"
                    id="item_images_attributes_${index}_url"><br>
                    <div class="js-remove">削除</div>
                  </div>`;
    return html;
  }

  let fileIndex = [1,2,3,4,5,6,7,8,9,10];

  $('#image-box').on('change', '.js-file', function(e) {
    $('#image-box').append(buildFileField(fileIndex[0]));
    fileIndex.shift();
    fileIndex.push(fileIndex[fileIndex.length - 1] + 1)
  });

  $('#image-box').on('click', '.js-remove', function() {
    $(this).parent().remove();
    if ($('.js-file').length == 0) $('#image-box').append(buildFileField(fileIndex[0]));
  });
});