import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var inputSourceManager: InputSourceManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cmd Switch")
                .font(.headline)

            Text("Choose the input sources that activate when you press each Command key.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Left Command")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("", selection: $inputSourceManager.leftCommandSourceID) {
                    Text("Not set").tag(nil as String?)
                    ForEach(inputSourceManager.availableSources) { source in
                        Text(source.localizedName).tag(source.id as String?)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Right Command")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("", selection: $inputSourceManager.rightCommandSourceID) {
                    Text("Not set").tag(nil as String?)
                    ForEach(inputSourceManager.availableSources) { source in
                        Text(source.localizedName).tag(source.id as String?)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            Button("Reload input sources") {
                inputSourceManager.refreshSources()
            }
            .buttonStyle(.link)
            .padding(.top, 8)
        }
        .padding(.top, 12)
        .frame(width: 260)
        .onAppear {
            inputSourceManager.refreshSources()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(InputSourceManager.shared)
    }
}
