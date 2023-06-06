function [Tsol,X,Usol,calls,calctime] = DifferenceMethodInt1D(N,f,kappa,u0,bounds,bc,bcf,tend,h,solver)
%computes an integro partial differential equation of form

%u_t=F(t,x,u,u_x,u_xx,g(t,x,u)) with g(t,x,u) = int_a^b kappa(t,y,x,u(y))dy

%input:

%f=@(t,x,u,ux,uxx,kappa)
%hereby kappa denotes the integro part:

%kappa=@(t,y,x,u)
%each time-step kappa is integrated numerically with
%respect to x

%u0=@(x)
%initial value

% bounds =[a,b]
%left and right bound of the spatialinterval b>a

%bc = [x,y]
% left and right boundary condition type (1=dirichlet, 2=neumann, 3=hubbabubba)

%bcf = {@(t),@(t)}
%eft and right boundary condition function

%tend= end-time

%h (optional) stepsize length (0=auto)
%solver (optional) {1,2,3}  time-solver type

lb=bounds(1);
rb=bounds(2);

lbc=bcf{1};
rbc=bcf{2};

tic;

if nargin<10
    solver=1;
end
if nargin<9
    h=0;
end

%determine dimension
dim=length(u0(lb));

l=rb-lb;
X=lb:l/(N-1):rb;
for ind=1:N
    u(ind,:)=u0(X(ind));
end

u=u(:);

calls=0;

if h>0
    options=odeset('AbsTol',10^20,'RelTol',10^20,'InitialStep',h,'MaxStep',h);
else
    options=odeset();
end

switch solver
    case 1
        [Tsol,Usol]=ode15s(@disc,[0,tend],u,options);
    case 2
        [Tsol,Usol]=ode45(@disc,[0,tend],u,options);
    case 3
        [Tsol,Usol]=ode23t(@disc,[0,tend],u,options);
end

Usol=reshape(Usol,[length(Tsol),N,dim]);
Usol=permute(Usol,[2,1,3]);

calctime=toc;

    function y= disc(t,u)
        u=reshape(u,[N,dim]);
        y=zeros(N,dim);
        [ux(1,:),ux(N,:),uxx(1,:),uxx(N,:)]=randwerte(t,u);
        kap=integropart(t,u);
        y(1,1:dim)=f(t,X(1),u(1,:),ux(1,:),uxx(1,:),kap(1));
        y(N,1:dim)=f(t,X(N),u(N,:),ux(N,:),uxx(N,:),kap(N));
        for i=2:N-1
            ux(i,1:dim)=(u(i+1,:)-u(i-1,:))/(2*l/(N-1));
            uxx(i,1:dim)=(u(i+1,:)-2*u(i,:)+u(i-1,:))/(l/(N-1))^2;
            y(i,1:dim)=f(t,X(i),u(i,:),ux(i,:),uxx(i,:),kap(i));
        end
        y=y(:);
        calls=calls+1;
        %waitbar(t/tend,WB,['Model time: ',num2str(t),', function calls: ',num2str(calls)]);
    end

    function kap = integropart(t,u)
        %equidistant trapezoidal method sum_i (u_i+u_(i+1))/2 *dx
        try
            kap=zeros(N,1);
            for j=1:N
                ka=kappa(t,X,X(j),u(j,:));
                if j==1 || j==N
                    ka=0.5*ka;
                end
                kap(1:N)=kap(1:N)+l/(N-1)*ka;
            end
        catch %if kappa is not vectorized
            kap=zeros(N,1);
            for i=1:N
                kap(i)=0;
                for j=1:N
                    ka=kappa(t,X(i),X(j),u(j,:));
                    if j==1 || j==N
                        ka=0.5*ka;
                    end
                    kap(i)=kap(i)+l/(N-1)*ka;
                end
            end
        end
    end

    function [ux1,uxN,uxx1,uxxN]=randwerte(t,u)
        ll=lbc(t)';
        rr=rbc(t)';
        if bc(1)==2
            ux1(1,1:dim)=ll(1:dim);
            ux2=(u(3,:)-u(1,:))/(2*l/(N-1));
            uxx1=(ux2-ux1)/(l/(N-1));
        elseif bc(1)==1
            ux1=(u(2,:)-ll(1:dim))/(2*l/(N-1));
            uxx1=(u(2,:)+ll(1:dim)-2*u(1,:))/(l/(N-1))^2;
        elseif bc(1)==3
            ux1=(u(2,:)-u(1,:))/(l/(N-1));
            uxx1=zeros(1,dim);
        end
        if bc(2)==2
            uxN(1,1:dim)=rr(1:dim);
            uxNm1=(u(N,:)-u(N-2,:))/(2*l/(N-1));
            uxxN=(uxN-uxNm1)/(l/(N-1));
        elseif bc(2)==1
            uxN=(rr(1:dim)-u(N-1,:))/(2*l/(N-1));
            uxxN=(u(N-1,:)+rr(1:dim)-2*u(N,:))/(l/(N-1))^2;
        elseif bc(2)==3
            uxN=(u(N,:)-u(N-1,:))/(l/(N-1));
            uxxN=zeros(1,dim);
        end
    end
end


