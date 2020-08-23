package main

import (
	"net/http"
)

type InnerHandler struct {
	Handle func(w http.ResponseWriter, r *http.Request)
}

func (ih InnerHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	ih.Handle(w, r)
}
