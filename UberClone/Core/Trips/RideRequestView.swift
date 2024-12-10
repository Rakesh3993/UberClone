//
//  RideRequestView.swift
//  UberClone
//
//  Created by Rakesh Kumar on 08/12/24.
//

import SwiftUI

struct RideRequestView: View {
    @State private var selectedRideType: RideType = .uberX
    @EnvironmentObject var viewModel: LocationSearchViewModel
    
    var body: some View {
        VStack {
            Capsule()
                .foregroundColor(Color(.systemGray5))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            // trip info view
            HStack {
                VStack {
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                        
                    Rectangle()
                        .fill(Color(.systemGray3))
                        .frame(width: 1, height: 32)
                    
                    Rectangle()
                        .fill(.black)
                        .frame(width: 8, height: 8)
                }
                .padding()
                
                VStack(alignment: .leading) {
                    HStack{
                        Text("Current location")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        if let pickUpTime = viewModel.pickUpTime {
                            Text(pickUpTime)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 16)
                    .padding(.trailing, 10) 
                    
                    HStack{
                        if let location = viewModel.selectedUberLocation {
                            Text("\(location.title)")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Spacer()
                    
                        if let dropOffTime = viewModel.dropOffTime {
                            Text(dropOffTime)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 10)
                }
            }
            .padding()
            
            Divider()
            
            // ride type selection view
            Text("Suggested Ride")
                .textCase(.uppercase)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding()
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(RideType.allCases) { type in
                        VStack(alignment: .leading) {
                            Image(type.imageName)
                                .resizable()
                                .scaledToFit()
                            
                            VStack(spacing: 5) {
                                Text(type.description)
                                    .font(.system(size: 14, weight: .semibold))
                                
                                Text(viewModel.calculateRidePrice(forType: type).toCurrency())
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.bottom, 5)
                            }
                            .padding(.bottom, 5)
                        }
                        .frame(width: 112, height: 140)
                        .foregroundColor(type == selectedRideType ? .white : .black)
                        .background(Color(type == selectedRideType ? .systemBlue : .systemGroupedBackground))
                        .scaleEffect(type == selectedRideType ? 1.15 : 1.0)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedRideType = type
                            }
                        }
                    }
                }
            }
            .padding()
            
            Divider()
            
            // payment option view
            
            HStack{
                Text("Visa")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(6)
                    .background(.blue)
                    .cornerRadius(4)
                    .foregroundColor(.white)
                    .padding(.leading)
                
                Text("**** 1234")
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .imageScale(.medium)
                    .padding()
                    
            }
            .frame(height: 50)
            .background(Color(.systemGroupedBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // request ride button
            Button {
                
            } label: {
                Text("CONFIRM RIDE")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    .background(.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, 20)
        .background(.white)
        .cornerRadius(20)
    }
}

#Preview {
    RideRequestView()
}
