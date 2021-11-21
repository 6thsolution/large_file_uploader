self.addEventListener('message', async (event) => {
    var method = event.data.method;
    var fileKeyInFormData = event.data.fileKeyInFormData;
    var uploadUrl = event.data.uploadUrl;
    var data = event.data.data;
    var headers = event.data.headers;
    var file = event.data.file;
    uploadFile(method, fileKeyInFormData, uploadUrl, data, headers, file);
});

function uploadFile(method, fileKeyInFormData, uploadUrl, data, headers, file) {
    var xhr = new XMLHttpRequest();
    var formdata = new FormData();
    var uploadPercent;

    setData(formdata, data);
    formdata.append(fileKeyInFormData, file);

    xhr.upload.addEventListener('progress', function (d) {
        if (d.lengthComputable) {
            uploadPercent = Math.floor((d.loaded / d.total) * 100);
            postMessage(uploadPercent);
        }
    }, false);
    xhr.onreadystatechange = function () {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            postMessage("done");
        }
    }
    xhr.onerror = function () {
        // only triggers if the request couldn't be made at all
        postMessage("request failed");
    };

    xhr.open(method, uploadUrl, true);
    setHeaders(xhr, headers);

    xhr.send(formdata);
}

function setData(formdata, data){
  for(let key in data){
    formdata.append(key, data[key])
  }
}

function setHeaders(xhr, headers){
  for(let key in headers){
    xhr.setRequestHeader(key, headers[key])
  }
}