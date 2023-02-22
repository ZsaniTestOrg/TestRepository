// Script to determine for which pillars to trigger the terraform plan job in the workflow
// How it works: collects all changed .tfvars files in a commit/PR, then creates a job matrix from them
//               - if a .tf file is changed, then the matrix will contain all pillars
// Inputs: CHANGED_FILES environment variable containing list of changed files in JSON format
// Outputs: An output variable called 'job-strategy-matrix', in JSON format, which can be used in the matrix strategy's 'include' section

const fs = require('fs');
const os = require('os');

const changedFilesInput = JSON.parse(process.env.CHANGED_FILES);
const addedOrModifiedFiles = changedFilesInput.addedOrModified;
const renamedFiles = changedFilesInput.renamed;

const changedFiles = [...addedOrModifiedFiles, ...renamedFiles];

let roleJobMatrix = [];
let changedRoleFiles = [];

console.log(changedFiles);
