//
//  ExerciseTableViewCell.m
//  SportManager
//
//  Created by Darya on 01/05/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "ExerciseTableViewCell.h"

@interface ExerciseTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation ExerciseTableViewCell

- (void)setExercise:(DMExercise *)exercise
{
    self.nameLabel.text = exercise.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM HH:mm";
    dateFormatter.locale = [NSLocale currentLocale];
    self.dateLabel.text = [dateFormatter stringFromDate:exercise.startDate];
}

@end
