from tornado.ioloop import IOLoop
import tornado.web
from extractors import extract_all
from time import time, localtime, strftime


class PageHandler(tornado.web.RequestHandler):
    def data_received(self, chunk):
        pass

    def get(self):
        self.write("<h1>Page server is up and running</h1>")

    def post(self):
        page_id = self.get_body_argument("page_id")
        page_html = self.get_body_argument("html")
        input_schools = self.get_body_arguments("input_schools")
        features = extract_all(page_html, input_schools)
        self.write({"features": features})
        print("Document {} is processed at {}".format(page_id, strftime("%d %b %Y %H:%M:%S", localtime(time()))))


class Application(tornado.web.Application):
    def __init__(self):
        handlers = [(r"/", PageHandler)]
        tornado.web.Application.__init__(self, handlers)


if __name__ == '__main__':
    app = Application()
    app.listen(8888)
    IOLoop.instance().start()

