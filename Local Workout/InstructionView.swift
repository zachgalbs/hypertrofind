import Foundation
import SwiftUI

struct InstructionsView: View {
    @ObservedObject var viewModel: SharedViewModel
    var body: some View {
        Text(viewModel.currentInstructions!)
    }
}
