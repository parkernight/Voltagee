import SwiftUI

struct GalleryItem: Identifiable {
    let id: String
    let name: String
    let medium: String
    let artist: String
    let url: String
}

let galleryItems: [GalleryItem] = [
    GalleryItem(id: "001", name: "Tengen Uzui", medium: "Traditional", artist: "Zero", url: "https://watchvoltage.com/photos/Tengen%20Uzui.png"),
    GalleryItem(id: "002", name: "Musketeer", medium: "Traditional", artist: "Zero", url: "https://watchvoltage.com/photos/Musketeer.png"),
    GalleryItem(id: "003", name: "Skeleton", medium: "Traditional", artist: "Kiri", url: "https://watchvoltage.com/photos/skeleton.png"),
    GalleryItem(id: "004", name: "Skull", medium: "Traditional", artist: "Zero", url: "https://watchvoltage.com/photos/skull.png"),
    GalleryItem(id: "005", name: "Deadpool", medium: "Traditional", artist: "Fried", url: "https://watchvoltage.com/photos/deadpool.png"),
    GalleryItem(id: "006", name: "JetBoy", medium: "Digital", artist: "JetBoy", url: "https://watchvoltage.com/photos/jetboy.png"),
    GalleryItem(id: "007", name: "Nezuko", medium: "Traditional", artist: "Zero", url: "https://watchvoltage.com/photos/Nezuko.png"),
    GalleryItem(id: "008", name: "Sanemi", medium: "Traditional", artist: "Zero", url: "https://watchvoltage.com/photos/sanemi.png"),
    GalleryItem(id: "009", name: "Frozen", medium: "Digital", artist: "Kiri", url: "https://watchvoltage.com/photos/frozen.png"),
    GalleryItem(id: "010", name: "Vigilante", medium: "Traditional", artist: "Fried", url: "https://watchvoltage.com/photos/vigilante.png"),
    GalleryItem(id: "011", name: "Spidey", medium: "Traditional", artist: "Fried", url: "https://watchvoltage.com/photos/spidey.png"),
    GalleryItem(id: "012", name: "Optimus", medium: "Traditional", artist: "Fried", url: "https://watchvoltage.com/photos/optimus.png"),
    GalleryItem(id: "013", name: "Kira", medium: "Traditional", artist: "Zero", url: "https://watchvoltage.com/photos/kira.png"),
    GalleryItem(id: "014", name: "The Perfect Human", medium: "Traditional", artist: "Bread", url: "https://watchvoltage.com/photos/christ.png"),
    GalleryItem(id: "015", name: "Angel", medium: "Traditional", artist: "Bread", url: "https://watchvoltage.com/photos/angel.png"),
    GalleryItem(id: "016", name: "Skull Knight", medium: "Traditional", artist: "Bread", url: "https://watchvoltage.com/photos/horsemen.png"),
    GalleryItem(id: "017", name: "Knight And Shining Armor", medium: "Traditional", artist: "Bread", url: "https://watchvoltage.com/photos/knight.png"),
    GalleryItem(id: "018", name: "Viv", medium: "Traditional", artist: "OriginZero", url: "https://watchvoltage.com/photos/viv.png"),
    GalleryItem(id: "019", name: "Nightcord", medium: "Traditional", artist: "OriginZero", url: "https://watchvoltage.com/photos/nightcord.png"),
    GalleryItem(id: "020", name: "Creature", medium: "Digital", artist: "ZD", url: "https://watchvoltage.com/photos/creature.png"),
    GalleryItem(id: "021", name: "Creature 2", medium: "Digital", artist: "ZD", url: "https://watchvoltage.com/photos/creature2.png"),
    GalleryItem(id: "022", name: "Claws", medium: "Traditional", artist: "Bread", url: "https://watchvoltage.com/photos/claws.png"),
    GalleryItem(id: "023", name: "Venom", medium: "Digital", artist: "Bread", url: "https://watchvoltage.com/photos/venom.png"),
    GalleryItem(id: "024", name: "Omni", medium: "Traditional", artist: "Bread", url: "https://watchvoltage.com/photos/omni.png"),
    GalleryItem(id: "025", name: "Wolf", medium: "Digital", artist: "Raven", url: "https://watchvoltage.com/photos/wolf.png"),
    GalleryItem(id: "026", name: "The Monster", medium: "Digital", artist: "JET", url: "https://watchvoltage.com/photos/themonster.png"),
    GalleryItem(id: "027", name: "Clash", medium: "Digital", artist: "JET", url: "https://watchvoltage.com/photos/sketch.png"),
    GalleryItem(id: "028", name: "Deceit", medium: "Digital", artist: "Delusional", url: "https://watchvoltage.com/photos/decit.png"),
    GalleryItem(id: "029", name: "Stare", medium: "Digital", artist: "Delusional", url: "https://watchvoltage.com/photos/stare.png"),
    GalleryItem(id: "030", name: "Hu Tao Genshin", medium: "Traditional", artist: "OriginZero", url: "https://watchvoltage.com/photos/hu.png"),
    GalleryItem(id: "031", name: "Shenhe Genshin", medium: "Traditional", artist: "OriginZero", url: "https://watchvoltage.com/photos/shen.png"),
    GalleryItem(id: "032", name: "Marito", medium: "Digital", artist: "Delusional", url: "https://watchvoltage.com/photos/marito.png"),
]
