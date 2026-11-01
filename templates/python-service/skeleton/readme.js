const nj=require('nunjucks'),fs=require('fs');
const env=new nj.Environment(null,{tags:{variableStart:'${{',variableEnd:'}}'},autoescape:false});
const values={name:'onboarding-api',description:'API de onboarding: de servicios',owner:'platform-team',serviceType:'lambda',templateVersion:'1.0.0',apis:[
 {name:'list-services',method:'GET',path:'/services'},{name:'get-service',method:'GET',path:'/services/{name}'}]};
const out=env.renderString(fs.readFileSync('/Users/jaime.henao/arheanja/personal-projects/Wenia/Repos/backstage-templates/templates/python-service/skeleton/../../../../../../Users/jaime.henao/arheanja/personal-projects/Wenia/Repos/backstage-templates/templates/python-service/skeleton/README.md','utf8'),{values});
fs.writeFileSync('README.rendered.md',out);
