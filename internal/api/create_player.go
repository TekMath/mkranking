package api

import (
	"encoding/json"
	"io"
	"log"
	"net/http"

	"github.com/thalkz/kart/internal/config"
	"github.com/thalkz/kart/internal/database"
)

type createPlayerRequest struct {
	Name string `json:"name"`
	Icon int    `json:"icon"`
}

type createPlayerResponse struct {
	Id int `json:"id"`
}

func CreatePlayer(w http.ResponseWriter, req *http.Request) error {
	b, err := io.ReadAll(req.Body)
	if err != nil {
		return err
	}
	var body createPlayerRequest
	err = json.Unmarshal(b, &body)
	if err != nil {
		return err
	}
	log.Printf("Creating %v\n", body.Name)

	id, err := database.CreatePlayer(body.Name, config.InitialRating, body.Icon)
	if err != nil {
		return err
	}
	return json.NewEncoder(w).Encode(
		&JsonResponse{
			Status: "ok",
			Data: &createPlayerResponse{
				Id: id,
			},
		},
	)
}