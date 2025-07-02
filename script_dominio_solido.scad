// Parâmetros do canal - definidos pelo tipo de reator
////// Reator usado: Miprowa Lab
L = 0.062; // [m] - Comprimento do insert na direção z - com acrescimo de 8mm para correcao da geometria final (retirada do triangulo)
H = 0.0015; // [m] - Altura do insert na direção x
B = 0.012; //[m] - Largura do insert na direção y

// Parâmetros do insert - mudam a geometria final 
d = 0.001; // [m] - Espessura da aleta
s = 0.002; // [m] - Distância em z (direção principal) entre as aletas
alpha = 45; // [dg] - Angulação das aletas


//Comprimento da linha diagonal baseado no Ângulo
L_dente = B / sin(alpha); // Calculado de acordo com o Ângulo

 //Criar bloco
module bloco() {
    cube([H/3, B, L], center = true); // Bloco com as dimensões de uma camada do insert
}

module aleta(d, alpha) {
    // Criacao de uma aleta considerando o angulo definido
    rotate([-alpha, 0, 0])
        cube([H/3, (L_dente + 1), d], center = true);
}

module canais(d, s, alpha) {
    // Loop para gerar todas as aletas desde o inicio até o final do insert
    for (i = [-L / 2 : s : L / 2]) {
        translate([0, 0, i])
            aleta(d, alpha);
    }
}

module camada_elemento_mistura() {
    difference() {
        bloco();
        canais(d, s, alpha);
    }
}

//Montar objeto simétrico ao longo do eixo Z
module uniao_camadas() {
    union() {
        // Primeira camada (superior)
            // Altura de Z=1 a Z=1.5 mm (centro em z = 1.25 mm)
        translate([(5/6*H-0.00001), 0, 0]) // Metade da altura acima de Z=0
            camada_elemento_mistura();

        // Segunda camada (meio)
             // Altura de Z=0.5 a Z=1 mm (centro em z = 0.75 mm)
        translate([H/2,0,0])
            rotate([0,0,180])
                camada_elemento_mistura();
        
        // Terceira camada (inferior)
             // Altura de Z=0 a Z=0.5 mm (centro em z = 0.25 mm)
        translate([H/6+0.00001,0,0])
                camada_elemento_mistura();
        //OBS.: Foi aplicado 0.00001 de deslocamento para haver sobreposição entre as camdadas e facilitar geração de malha

    }   
}
// Correção final na geometria para retirada de objetos triangulares gerados
//   na diferença entre o bloco inicial e os canais
module correcao_triangulo() {
    union () {
    translate([0,-B/2,-0.031])
    cube([H+0.0001, B, 0.006], center = false);

    translate([0,-B/2,0.025])
    cube([H+0.00001, B, 0.006], center = false);
    }
}

module insert() {
    difference() {
    uniao_camadas();
    correcao_triangulo();
    }
}
// Chamada final para gerar o insert
insert();