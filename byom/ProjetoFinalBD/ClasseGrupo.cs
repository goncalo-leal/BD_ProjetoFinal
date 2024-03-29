﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjetoFinalBD
{
    public class ClasseGrupo
    {
        private int id;
        private String nome;
        private int cadeira;
        private String codigo_criador;

        public ClasseGrupo(int id, string nome, int cadeira, string codigo_criador)
        {
            this.id = id;
            this.nome = nome;
            this.cadeira = cadeira;
            this.codigo_criador = codigo_criador;
        }

        public int Id { get => id; set => id = value; }
        public string Nome { get => nome; set => nome = value; }
        public int Cadeira { get => cadeira; set => cadeira = value; }
        public string Codigo_criador { get => codigo_criador; set => codigo_criador = value; }
    }
}
